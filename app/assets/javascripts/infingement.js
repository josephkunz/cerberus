const selectTimer =  document.getElementById("select-timer");
const playButton = document.getElementById("play-button");
const snapshotButton = document.getElementById("snapshot-button");
const exportButton = document.getElementById("export-button");
const csfrToken = document.head.querySelector("[name~=csrf-token][content]").content;

// Select items
const selectMenu = document.querySelector(".select-menu-infringement")
const checkBoxes = document.querySelectorAll(".card-trip-checkbox");
const checkCards = document.querySelectorAll(".card-trip-checkcard");
const selectedText = document.querySelectorAll(".selected-text span");
const selectAllButton = document.getElementById("select-button");
const deselectAllButton = document.getElementById("deselect-button");
const invertSelectionButton = document.getElementById("invert-button");
let numberOfSelected = 0;

if (selectTimer != null) {
  selectTimer.addEventListener("change", (event) => {
    Rails.ajax({
      url: "",
      type: "put",
      data: `interval=${selectTimer.value}`,
      success: (data) => { console.log(data); },
      error: (data) => {}
    })
  });

  playButton.addEventListener("click", (event) => {
    let state = "";
    if (playButton.innerText === "Stop")  {
      state = "Stop";
    } else {
      state = "Start";
    }

    Rails.ajax({
      url: "",
      type: "put",
      data: `state=${state}&interval=${selectTimer.value}`,
      success: (data) => { console.log(data); },
      error: (data) => {}
    })
  });

  snapshotButton.addEventListener("click", (event) => {
    Rails.ajax({
      url: "",
      type: "put",
      data: `snapshot=true`,
      success: (data) => { console.log(data); },
      error: (data) => {}
    })
  });

  exportButton.addEventListener("click", (event) => {
    Rails.ajax({
      url: window.location.pathname + "/createzip",
      type: "get",
      data: `files=${selectedParametersString()}`,
      success: (data) => { console.log(data); },
      error: (data) => {}
    })
  });

  setInterval(function() {
    const snapshotCards = document.querySelectorAll("#snapshot-card");
    Rails.ajax({
      url: window.location.pathname + "/refresh",
      type: "get",
      dataType: "script",
      data: `snapshots=${snapshotCards.length}`,
      success: (data) => { console.log(data); },
      error: (data) => {}
    })
  }, 5000);



  // Select functions and actions

  const selectedParametersString = () => {
    let selectedString = "";
    for (let i = 0; i < checkBoxes.length; i += 1) {
      if (checkBoxes[i].dataset.checked === "true") {
        selectedString += "_" + i.toString();
      }
    }
    return selectedString.substring(1);
  }

  const updateSelectedCount = () => {
    selectedText[0].innerText = `${numberOfSelected} Selected`;
  }

  const updateExportButton = () => {
    if (numberOfSelected === 0 || numberOfSelected === checkBoxes.length) {
      exportButton.innerText = `Export All`;
    } else {
      exportButton.innerText = `Export (${numberOfSelected})`
    }
  }

  const showSelectMenu = () => {
    selectMenu.style.visibility = "visible";
  }

  const hideSelectMenu = () => {
    selectMenu.style.visibility = null;
  }

  const showCheckCards = () => {
    for (let i = 0; i < checkCards.length; i += 1) {
      checkCards[i].style.visibility = "visible";
    }
  }

  const hideCheckCards = () => {
    let checkFlag = false
    for (let i = 0; i < checkBoxes.length; i += 1) {
      if (checkBoxes[i].dataset.checked === "true") {
        checkFlag = true;
        break;
      }
    }
    if (checkFlag === false) {
      for (let i = 0; i < checkCards.length; i += 1) {
        checkCards[i].style.visibility = null;
      }
      hideSelectMenu();
    }
  }

  const checkBoxClick = (event) => {
    if (event.target.parentElement.dataset.checked === "false")  {// innerHTML.includes("fa-square")) {
      event.target.parentElement.dataset.checked = "true";
      numberOfSelected += 1;
      updateSelectedCount();
      updateExportButton();
      showCheckCards();
      showSelectMenu();
      event.target.parentElement.innerHTML = '<i class="far fa-check-square"></i>';
    } else {
      event.target.parentElement.dataset.checked = "false";
      numberOfSelected -= 1;
      updateSelectedCount();
      updateExportButton();
      hideCheckCards();
      event.target.parentElement.innerHTML = '<i class="far fa-square"></i>';
    }
  }

  for (let i = 0; i < checkBoxes.length; i += 1) {
    checkBoxes[i].addEventListener("click", checkBoxClick);
  }

  selectAllButton.addEventListener("click", (event) => {
    for (let i = 0; i < checkBoxes.length; i += 1) {
      checkBoxes[i].dataset.checked = "true";
      checkBoxes[i].innerHTML = '<i class="far fa-check-square"></i>';
    }
    numberOfSelected = checkBoxes.length;
    updateSelectedCount();
    updateExportButton();
  });

  deselectAllButton.addEventListener("click", (event) => {
    for (let i = 0; i < checkBoxes.length; i += 1) {
      checkBoxes[i].dataset.checked = "false";
      checkBoxes[i].innerHTML = '<i class="far fa-square"></i>';
      checkCards[i].style.visibility = null;
    }
    numberOfSelected = 0;
    updateSelectedCount();
    updateExportButton();
    hideSelectMenu();
  });

  invertSelectionButton.addEventListener("click", (event) => {
    for (let i = 0; i < checkBoxes.length; i += 1) {
      if (checkBoxes[i].dataset.checked === "true") {
        checkBoxes[i].dataset.checked = "false"
        checkBoxes[i].innerHTML = '<i class="far fa-square"></i>';
      } else {
        checkBoxes[i].dataset.checked = "true";
        checkBoxes[i].innerHTML = '<i class="far fa-check-square"></i>';
      }
    }
    numberOfSelected = checkBoxes.length - numberOfSelected;
    if (numberOfSelected === 0) {
      hideSelectMenu();
    }
    hideCheckCards();
    updateSelectedCount();
    updateExportButton();
  });
}

