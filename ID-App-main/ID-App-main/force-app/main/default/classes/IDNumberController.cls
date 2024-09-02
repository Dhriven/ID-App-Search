/*******************************************************************
* @Class Name        :  IDNumberController
* @Test Class        :  IDNumberControllerTest
* @Author            :  Dhriven
* @Last Modified By  :  Dhriven, 02-Sept-2024
* @Version           :  1.0
*
*******************************************************************/

public with sharing class IDNumberController {
    
    static List<Calendarific_API_Settings__mdt> apiSettings = Calendarific_API_Settings__mdt.getAll().values();
    
    @AuraEnabled
    public static Boolean validateID(String idNumber) {
        // Check if the ID number is null, not 13 digits long, non-numeric, or consists of all zeros
        if (idNumber == null || idNumber.length() != 13 || !idNumber.isNumeric() || idNumber.equals('0000000000000')) {
            return false; // Return false if any of the above conditions are true, indicating an invalid ID number
        }
        
        Integer sum = 0; // Initialize the sum variable to store the cumulative total
        // Loop through each digit of the ID number, from left to right
        for (Integer i = 0; i < idNumber.length(); i++) {
            Integer digit = Integer.valueOf(idNumber.substring(i, i+1)); // Extract the digit at position 'i'
            
            // Double every second digit starting from the second position (index 1)
            if (Math.mod(i, 2) == 1) {
                digit *= 2; // Double the digit
                if (digit > 9) digit -= 9; // If the result is greater than 9, subtract 9 (equivalent to summing the digits of the result)
            }
            
            sum += digit; // Add the digit (doubled and adjusted if necessary) to the sum
        }
        
        // Return true if the sum is divisible by 10, indicating a valid ID number according to the Luhn algorithm
        return Math.mod(sum, 10) == 0;
    }
    
    
    @AuraEnabled
    public static IDInfo processID(String idNumber) {
        IDInfo info = decodeIDNumber(idNumber);
        
        // Create a new record object with the ID number and increment the query count by default
        ID_Tracking__c record = new ID_Tracking__c(ID_Number__c = idNumber, 
                                                   Date_of_Birth__c = Date.valueOf(info.dateOfBirth), 
                                                   Gender__c = info.gender, 
                                                   Citizenship__c = info.citizenship);
        
        // Try to query for an existing record
        List<ID_Tracking__c> existingRecords = [SELECT Id, Query_Count__c FROM ID_Tracking__c WHERE ID_Number__c = :idNumber LIMIT 1];
        
        if (!existingRecords.isEmpty()) {
            // If the record exists, increment the query count
            record.Id = existingRecords[0].Id;
            record.Query_Count__c = existingRecords[0].Query_Count__c + 1;
        } else {
            // If the record doesn't exist, set the query count to 1
            record.Query_Count__c = 1;
        }
        
        // Upsert the record (insert if new, update if exists)
        upsert record;
        
        return info;
    }
    
    
    
    public static IDInfo decodeIDNumber(String idNumber) {
        String dob = idNumber.substring(0, 6);
        Integer genderDigit = Integer.valueOf(idNumber.substring(6, 7));
        String gender = genderDigit >= 5 ? 'Male' : 'Female';
        String citizenship = idNumber.substring(10, 11) == '0' ? 'SA Citizen' : 'Permanent Resident';
        
        String year = dob.substring(0, 2);
        System.debug('year: ' + year);
        if (year.startsWith('0') || year.startsWith('1')) {
            year = '20' + year;
        } else {
            year = '19' + year;
        }
        dob = year + '-' + dob.substring(2, 4) + '-' + dob.substring(4, 6);
        System.debug('dob: '+ dob);
        return new IDInfo(dob, gender, citizenship);
    }
    
    @AuraEnabled
    public static List<Holiday> getHolidays(String year) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiSettings[0].URL_Endpoint__c+'?api_key='+ apiSettings[0].API_Key__c +'&country=' + apiSettings[0].Country_Code__c + '&year=' + year);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<Holiday> holidays = new List<Holiday>();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> responseMap = (Map<String, Object>) results.get('response');
            List<Object> holidaysData = (List<Object>) responseMap.get('holidays');
            for (Object holidayObj : holidaysData) {
                Map<String, Object> holidayMap = (Map<String, Object>) holidayObj;
                holidays.add(new Holiday((String) holidayMap.get('name'), (String) ((Map<String, Object>) holidayMap.get('date')).get('iso')));
            }
            return holidays;
        } else {
            throw new AuraHandledException('Failed to retrieve holidays from API.');
        }
    }
    
    
    public class IDInfo {
        @AuraEnabled public String dateOfBirth;
        @AuraEnabled public String gender;
        @AuraEnabled public String citizenship;
        
        public IDInfo(String dob, String gender, String citizenship) {
            this.dateOfBirth = dob;
            this.gender = gender;
            this.citizenship = citizenship;
        }
    }
    
    public class Holiday {
        @AuraEnabled public String name;
        @AuraEnabled public String holiday_date;
        
        public Holiday(String name, String holiday_date) {
            this.name = name;
            this.holiday_date = holiday_date;
        }
    }
}