@IsTest
private class ExternalSearchTests {
  @IsTest
  static void testPositiveMocking() {
    // GIVEN
    HTTPMockFactory mock = new HTTPMockFactory(
      200,
      'OK',
      'I found it!',
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, mock);
    // WHEN
    Test.startTest();
    String result = ExternalSearch.googleIt('epic search');
    Test.stopTest();
    // THEN
    Assert.areEqual('I found it!', result, 'Expected to receive mock response');
  }

  @IsTest
  static void testNegativeMocking() {
    // GIVEN
    HTTPMockFactory mock = new HTTPMockFactory(
      500,
      'Internal Server Error',
      'The server encountered an unexpected condition that prevented it from fulfilling the request',
      new Map<String, String>()
    );
    Test.setMock(HttpCalloutMock.class, mock);
    // WHEN
    try {
      Test.startTest();
      String result = ExternalSearch.googleIt('epic search');
      Test.stopTest();
      Assert.areEqual(
        'The server encountered an unexpected condition that prevented it from fulfilling the request',
        result,
        'Expected to receive mock response'
      );
      Assert.fail(
        'The server encountered an unexpected condition that prevented it from fulfilling the request'
      );
    } catch (ExternalSearch.ExternalSearchException e) {
      System.debug(e.getMessage());
      Assert.isTrue(
        e.getMessage()
          .equalsIgnoreCase('Did not receive a 200 status code: ' + '500'),
        'Exception message does match: ' + e.getMessage()
      );
    }
  }
}
