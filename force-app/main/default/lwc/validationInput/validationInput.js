import { LightningElement, track, api } from "lwc";

export default class ValidationInput extends LightningElement {
  @api pattern = "*____***";

  @track inputFields = [];
  @track finalValue = ""; // To store the final result

  connectedCallback() {
    this.initializeFields();
  }

  initializeFields() {
    this.inputFields = this.pattern.split("").map((char, index) => {
      return {
        id: `field-${index}`, // Generate a unique id for each field
        value: char === "_" ? "" : char,
        isEditable: char === "_"
      };
    });
  }

  handleInput(event) {
    const index = event.target.dataset.id;
    const value = event.target.value.replace(/[^0-9]/, ""); // Ensure only digits are entered

    if (value) {
      this.inputFields.find((field) => field.id === index).value = value;
    }

    // Update the final value
    this.updateFinalValue();

    // Move focus to the next editable field
    const nextIndex =
      this.inputFields.findIndex((field) => field.id === index) + 1;
    if (
      nextIndex < this.inputFields.length &&
      this.inputFields[nextIndex].isEditable
    ) {
      this.template
        .querySelector(`input[data-id="${this.inputFields[nextIndex].id}"]`)
        .focus();
    }
  }

  updateFinalValue() {
    this.finalValue = this.inputFields
      .map((field) => field.value || field.id.replace("field-", ""))
      .join("");
    console.log("Final Value:", this.finalValue);
  }
}
