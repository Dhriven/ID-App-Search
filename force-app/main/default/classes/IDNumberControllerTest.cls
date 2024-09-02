/*******************************************************************
* @Class Name        :  IDNumberControllerTest
* @Author            :  Dhriven
* @Last Modified By  :  Dhriven, 02-Sept-2024
* @Version           :  1.0
*
*******************************************************************/

@IsTest
public class IDNumberControllerTest {
    
    @IsTest
    static void testValidateID() {
        // Valid ID number with correct Luhn check digit
        String validID = '8001015009087';
        Boolean isValid = IDNumberController.validateID(validID);
        System.assertEquals(true, isValid, 'The ID number should be valid.');
        
        // Invalid ID number with incorrect Luhn check digit
        String invalidID = '8001015009088';
        Boolean isInvalid = IDNumberController.validateID(invalidID);
        System.assertEquals(false, isInvalid, 'The ID number should be invalid.');
        
        // ID number with all zeros
        String allZerosID = '0000000000000';
        Boolean isAllZerosInvalid = IDNumberController.validateID(allZerosID);
        System.assertEquals(false, isAllZerosInvalid, 'The ID number with all zeros should be invalid.');
        
        // ID number with non-numeric characters
        String nonNumericID = '800101ABCDE01';
        Boolean isNonNumericInvalid = IDNumberController.validateID(nonNumericID);
        System.assertEquals(false, isNonNumericInvalid, 'The ID number with non-numeric characters should be invalid.');
        
        // Null ID number
        Boolean isNullInvalid = IDNumberController.validateID(null);
        System.assertEquals(false, isNullInvalid, 'The null ID number should be invalid.');
        
        // ID number that is not 13 digits long
        String shortID = '80010150090';
        Boolean isShortInvalid = IDNumberController.validateID(shortID);
        System.assertEquals(false, isShortInvalid, 'The short ID number should be invalid.');
    }
    
    @IsTest
    static void testProcessID() {
        // Use a valid ID number
        String validID = '8001015009087'; // 1980-01-01, Male, SA Citizen
        
        // Process the ID
        IDNumberController.IDInfo info = IDNumberController.processID(validID);
        
        // Assert that the correct date of birth, gender, and citizenship are returned
        System.assertEquals('1980-01-01', info.dateOfBirth, 'The date of birth should be 1980-01-01.');
        System.assertEquals('Male', info.gender, 'The gender should be Male.');
        System.assertEquals('SA Citizen', info.citizenship, 'The citizenship should be SA Citizen.');
        
        // Check that the record was inserted and the query count is 1
        ID_Tracking__c record = [SELECT Query_Count__c FROM ID_Tracking__c WHERE ID_Number__c = :validID];
        System.assertEquals(1, record.Query_Count__c, 'The query count should be 1.');
        
        // Process the ID again and check that the query count increments
        info = IDNumberController.processID(validID);
        record = [SELECT Query_Count__c FROM ID_Tracking__c WHERE ID_Number__c = :validID];
        System.assertEquals(2, record.Query_Count__c, 'The query count should be 2 after the second process.');
    }
    
    @IsTest
    static void testGetHolidays() {
        // Mock the callout to return a predefined response
        Test.setMock(HttpCalloutMock.class, new MockCalendarificAPIResponse());
        
        // Test getHolidays with a valid year
        List<IDNumberController.Holiday> holidays = IDNumberController.getHolidays('2024');
        
        // Assert that holidays are returned
        System.assert(holidays != null && holidays.size() > 0, 'Holidays should be returned.');
        System.assertEquals('New Year\'s Day', holidays[0].name, 'The first holiday should be New Year\'s Day.');
    }
    
    @IsTest
    static void testDecodeIDNumberv1() {
        // Use a valid ID number
        String validID = '8001015009087'; // 1980-01-01, Male, SA Citizen
        
        // Decode the ID number
        IDNumberController.IDInfo info = IDNumberController.decodeIDNumber(validID);
        
        // Assert that the correct date of birth, gender, and citizenship are returned
        System.assertEquals('1980-01-01', info.dateOfBirth, 'The date of birth should be 1980-01-01.');
        System.assertEquals('Male', info.gender, 'The gender should be Male.');
        System.assertEquals('SA Citizen', info.citizenship, 'The citizenship should be SA Citizen.');
    }
    
    @IsTest
    static void testDecodeIDNumberv2() {
        // Use a valid ID number where the year starts with '1' (e.g., 2015)
        String idWith2015Year = '1501015800085'; // 2015-01-01, Male, SA Citizen
        IDNumberController.IDInfo info2015 = IDNumberController.decodeIDNumber(idWith2015Year);
        System.assertEquals('2015-01-01', info2015.dateOfBirth, 'The date of birth should be 2015-01-01.');
        System.assertEquals('Male', info2015.gender, 'The gender should be Male.');
        System.assertEquals('SA Citizen', info2015.citizenship, 'The citizenship should be SA Citizen.');
    }
    
    

    
    @IsTest
    static void testGetHolidaysFailure() {
        // Mock the callout to return a non-200 status code
        Test.setMock(HttpCalloutMock.class, new MockCalendarificAPIErrorResponse());
        
        try {
            // This should trigger the exception
            List<IDNumberController.Holiday> holidays = IDNumberController.getHolidays('2024');
            System.assert(false, 'Expected an AuraHandledException to be thrown.');
        } catch (Exception e) {
            // Check if the exception is an instance of AuraHandledException
            System.assert(e instanceof AuraHandledException, 'Expected an AuraHandledException to be thrown.');
        }
    }
    
    
    
    // Mock HTTP Callout for Calendarific API
    private class MockCalendarificAPIResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"response": {"holidays": [{"name": "New Year\'s Day", "date": {"iso": "2024-01-01"}}]}}');
            return res;
        }
    }
    
    // Mock HTTP Callout for Calendarific API failure
    private class MockCalendarificAPIErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500); // Simulate a server error
            res.setBody('{"error": "Internal Server Error"}');
            return res;
        }
    }
}