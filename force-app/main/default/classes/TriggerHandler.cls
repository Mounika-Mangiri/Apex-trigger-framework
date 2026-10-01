/**
 * Base class for one-trigger-per-object handlers.
 *
 * Subclasses override only the events they need. The base class adds:
 *  - a kill switch per handler (Trigger_Setting__mdt.Is_Active__c),
 *  - a programmatic bypass for data loads and nested DML,
 *  - a loop breaker: a handler runs at most maxRuns times per event per
 *    transaction (default 10), which stops runaway recursion without
 *    skipping legitimate second updates the way a static Boolean would.
 */
@SuppressWarnings(
  'PMD.EmptyStatementBlock'
) // event hooks are intentionally empty
public virtual class TriggerHandler {
  private static Set<String> bypassed = new Set<String>();
  private static Map<String, Integer> runCounts = new Map<String, Integer>();

  /** Test seam: handler name -> active flag, used instead of custom metadata. */
  @TestVisible
  private static Map<String, Boolean> settingOverrides = new Map<String, Boolean>();

  protected System.TriggerOperation operation;
  protected List<SObject> newList;
  protected Map<Id, SObject> oldMap;

  protected Integer maxRuns = 10;

  public TriggerHandler() {
    if (Trigger.isExecuting) {
      this.operation = Trigger.operationType;
      this.newList = Trigger.new;
      this.oldMap = Trigger.oldMap;
    }
  }

  public void run() {
    if (!shouldRun()) {
      return;
    }
    switch on operation {
      when BEFORE_INSERT {
        beforeInsert(newList);
      }
      when BEFORE_UPDATE {
        beforeUpdate(newList, oldMap);
      }
      when BEFORE_DELETE {
        beforeDelete(oldMap);
      }
      when AFTER_INSERT {
        afterInsert(newList);
      }
      when AFTER_UPDATE {
        afterUpdate(newList, oldMap);
      }
      when AFTER_DELETE {
        afterDelete(oldMap);
      }
      when AFTER_UNDELETE {
        afterUndelete(newList);
      }
    }
  }

  // ---- bypass API -------------------------------------------------------

  public static void bypass(String handlerName) {
    bypassed.add(handlerName);
  }

  public static void clearBypass(String handlerName) {
    bypassed.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) {
    return bypassed.contains(handlerName);
  }

  @TestVisible
  private static void resetRunCounts() {
    runCounts.clear();
  }

  // ---- events to override -------------------------------------------------

  protected virtual void beforeInsert(List<SObject> records) {
  }
  protected virtual void beforeUpdate(
    List<SObject> records,
    Map<Id, SObject> oldRecords
  ) {
  }
  protected virtual void beforeDelete(Map<Id, SObject> oldRecords) {
  }
  protected virtual void afterInsert(List<SObject> records) {
  }
  protected virtual void afterUpdate(
    List<SObject> records,
    Map<Id, SObject> oldRecords
  ) {
  }
  protected virtual void afterDelete(Map<Id, SObject> oldRecords) {
  }
  protected virtual void afterUndelete(List<SObject> records) {
  }

  // ---- internals ------------------------------------------------------------

  @TestVisible
  private String handlerName() {
    return String.valueOf(this).substringBefore(':');
  }

  private Boolean shouldRun() {
    String name = handlerName();
    if (operation == null || isBypassed(name) || !isActive(name)) {
      return false;
    }
    String key = name + '.' + operation;
    Integer count = runCounts.containsKey(key) ? runCounts.get(key) : 0;
    if (count >= maxRuns) {
      return false;
    }
    runCounts.put(key, count + 1);
    return true;
  }

  private static Boolean isActive(String name) {
    if (settingOverrides.containsKey(name)) {
      return settingOverrides.get(name);
    }
    Trigger_Setting__mdt setting = Trigger_Setting__mdt.getInstance(name);
    // No record means active: new handlers work without extra setup.
    return setting == null || setting.Is_Active__c;
  }
}
