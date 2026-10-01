@IsTest
private class AccountTriggerHandlerTest {
  @IsTest
  static void normalizesOnInsertAndUpdate() {
    Account acc = new Account(
      Name = 'Sample Holdings',
      Phone = '919.555.0123',
      Fax = '+1 919 555 0199',
      BillingPostalCode = '276011234'
    );
    insert acc;
    acc = [
      SELECT Phone, Fax, BillingPostalCode
      FROM Account
      WHERE Id = :acc.Id
    ];
    Assert.areEqual('(919) 555-0123', acc.Phone);
    Assert.areEqual('(919) 555-0199', acc.Fax);
    Assert.areEqual('27601-1234', acc.BillingPostalCode);

    acc.Phone = '9195550100';
    update acc;
    acc = [SELECT Phone FROM Account WHERE Id = :acc.Id];
    Assert.areEqual('(919) 555-0100', acc.Phone);
  }

  @IsTest
  static void bypassLeavesValuesUntouched() {
    TriggerHandler.bypass('AccountTriggerHandler');
    Account acc = new Account(Name = 'Raw Data Load', Phone = '919.555.0123');
    insert acc;
    TriggerHandler.clearBypass('AccountTriggerHandler');
    acc = [SELECT Phone FROM Account WHERE Id = :acc.Id];
    Assert.areEqual('919.555.0123', acc.Phone);
  }

  @IsTest
  static void bulkInsertOf200() {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < 200; i++) {
      accounts.add(
        new Account(
          Name = 'Bulk ' + i,
          Phone = '9195550' + String.valueOf(100 + i)
        )
      );
    }
    insert accounts;
    Assert.areEqual(
      200,
      [SELECT COUNT() FROM Account WHERE Phone LIKE '(919) 555-%']
    );
  }
}
