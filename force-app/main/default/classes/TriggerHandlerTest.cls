@IsTest
private class TriggerHandlerTest {
  /** Records which events fired. */
  private class SpyHandler extends TriggerHandler {
    public List<String> calls = new List<String>();

    public SpyHandler(System.TriggerOperation op, Integer runs) {
      this.operation = op;
      this.newList = new List<Account>{ new Account(Name = 'Spy') };
      this.oldMap = new Map<Id, SObject>();
      this.maxRuns = runs;
    }

    protected override void beforeInsert(List<SObject> records) {
      calls.add('beforeInsert');
    }
    protected override void beforeUpdate(
      List<SObject> records,
      Map<Id, SObject> oldRecords
    ) {
      calls.add('beforeUpdate');
    }
    protected override void beforeDelete(Map<Id, SObject> oldRecords) {
      calls.add('beforeDelete');
    }
    protected override void afterInsert(List<SObject> records) {
      calls.add('afterInsert');
    }
    protected override void afterUpdate(
      List<SObject> records,
      Map<Id, SObject> oldRecords
    ) {
      calls.add('afterUpdate');
    }
    protected override void afterDelete(Map<Id, SObject> oldRecords) {
      calls.add('afterDelete');
    }
    protected override void afterUndelete(List<SObject> records) {
      calls.add('afterUndelete');
    }
  }

  @IsTest
  static void dispatchesEveryOperation() {
    Map<System.TriggerOperation, String> expected = new Map<System.TriggerOperation, String>{
      System.TriggerOperation.BEFORE_INSERT => 'beforeInsert',
      System.TriggerOperation.BEFORE_UPDATE => 'beforeUpdate',
      System.TriggerOperation.BEFORE_DELETE => 'beforeDelete',
      System.TriggerOperation.AFTER_INSERT => 'afterInsert',
      System.TriggerOperation.AFTER_UPDATE => 'afterUpdate',
      System.TriggerOperation.AFTER_DELETE => 'afterDelete',
      System.TriggerOperation.AFTER_UNDELETE => 'afterUndelete'
    };
    for (System.TriggerOperation op : expected.keySet()) {
      SpyHandler spy = new SpyHandler(op, 10);
      spy.run();
      Assert.areEqual(new List<String>{ expected.get(op) }, spy.calls);
    }
  }

  @IsTest
  static void bypassSkipsHandler() {
    SpyHandler spy = new SpyHandler(System.TriggerOperation.BEFORE_INSERT, 10);
    String name = spy.handlerName();
    TriggerHandler.bypass(name);
    Assert.isTrue(TriggerHandler.isBypassed(name));
    spy.run();
    Assert.areEqual(0, spy.calls.size());

    TriggerHandler.clearBypass(name);
    spy.run();
    Assert.areEqual(1, spy.calls.size());
  }

  @IsTest
  static void killSwitchSkipsHandler() {
    SpyHandler spy = new SpyHandler(System.TriggerOperation.AFTER_UPDATE, 10);
    TriggerHandler.settingOverrides.put(spy.handlerName(), false);
    spy.run();
    Assert.areEqual(0, spy.calls.size());
  }

  @IsTest
  static void loopBreakerStopsAfterMaxRuns() {
    SpyHandler spy = new SpyHandler(System.TriggerOperation.AFTER_UPDATE, 2);
    spy.run();
    spy.run();
    spy.run();
    Assert.areEqual(2, spy.calls.size());

    TriggerHandler.resetRunCounts();
    spy.run();
    Assert.areEqual(3, spy.calls.size());
  }

  @IsTest
  static void outsideTriggerContextDoesNothing() {
    SpyHandler spy = new SpyHandler(null, 10);
    spy.run();
    Assert.areEqual(0, spy.calls.size());
  }
}
