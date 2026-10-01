/**
 * Example handler: normalizes U.S. phone numbers and postal codes on Account
 * so duplicate rules and integrations see one format.
 */
public with sharing class AccountTriggerHandler extends TriggerHandler {
  protected override void beforeInsert(List<SObject> records) {
    normalize((List<Account>) records);
  }

  protected override void beforeUpdate(
    List<SObject> records,
    Map<Id, SObject> oldRecords
  ) {
    normalize((List<Account>) records);
  }

  private static void normalize(List<Account> accounts) {
    for (Account acc : accounts) {
      acc.Phone = FormatUtils.usPhone(acc.Phone);
      acc.Fax = FormatUtils.usPhone(acc.Fax);
      acc.BillingPostalCode = FormatUtils.usZip(acc.BillingPostalCode);
    }
  }
}
