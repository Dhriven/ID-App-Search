@IsTest
private class CalculatorTests {
  @IsTest
  static void testDivideByZero() {
    // WHEN
    try {
      Test.startTest();
      Calculator.divide(10, 0);
      Test.stopTest();
      Assert.fail('An exception should have been thrown');
    } catch (Calculator.CalculatorException e) {
      // THEN
      System.debug(e.getMessage());
      Assert.isTrue(
        e.getMessage().equalsIgnoreCase('You still can\'t divide by zero'),
        'Exception message does match: ' + e.getMessage()
      );
    }
  }
}
