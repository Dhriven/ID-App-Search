@IsTest
private class MyDataGenerationTests {
  @TestSetup
  static void loadTestDataFromStaticResource() {
    // GIVEN
    List<sObject> accounts = Test.loadData(
      Account.SObjectType,
      'otherAccountData'
    );
  }
  @IsTest
  static void testLoadOtherAccountsFromStaticResource() {
    // WHEN
    List<Account> accts = [SELECT ID FROM Account];
    // THEN
    Assert.isTrue(accts.size() == 15, 'Expected 15 accounts');
  }
}
