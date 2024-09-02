import { LightningElement, track } from "lwc";
import validateID from "@salesforce/apex/IDNumberController.validateID";
import processID from "@salesforce/apex/IDNumberController.processID";
import getHolidays from "@salesforce/apex/IDNumberController.getHolidays";

export default class IdNumberSearch extends LightningElement {
  @track idNumber = "";
  @track isButtonDisabled = true;
  @track errorMessage = "";
  @track holidays = null;
  @track isLoading = false; // Track loading state

  dateOfBirth = ""; // Store DOB to compare with holidays

  handleInputChange(event) {
    this.idNumber = event.target.value;
    this.validateIDNumber();
  }

  validateIDNumber() {
    // Server-side validation using Apex
    validateID({ idNumber: this.idNumber })
      .then((result) => {
        this.isButtonDisabled = !result;
        this.errorMessage = result
          ? ""
          : "Invalid ID Number. Please enter a valid 13-digit SA ID Number.";
      })
      .catch((error) => {
        console.error("Error in validation:", error);
        this.errorMessage = "An error occurred during validation.";
      });
  }

  handleSearch() {
    this.isLoading = true; // Start loading
    processID({ idNumber: this.idNumber })
      .then((result) => {
        this.errorMessage = "";
        this.dateOfBirth = result.dateOfBirth; // Store DOB for comparison
        return getHolidays({ year: this.dateOfBirth.split("-")[0] });
      })
      .then((holidayResult) => {
        this.holidays = holidayResult.map((holiday) => {
          // Check if the holiday date matches the DOB
          const isBirthday = holiday.holiday_date === this.dateOfBirth;
          // Add a class property to the holiday object
          holiday.cssClass = isBirthday ? "highlight-birthday" : "";
          return holiday;
        });
        this.isLoading = false; // Stop loading
      })
      .catch((error) => {
        console.error("Error in processing or fetching holidays:", error);
        this.errorMessage =
          "An error occurred while processing the ID number or fetching holidays.";
        this.isLoading = false; // Stop loading
      });
  }
}
