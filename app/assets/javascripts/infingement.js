const selectTimer =  document.getElementById("select-timer");
const playButton = document.getElementById("play-button");
const snapshotButton = document.getElementById("snapshot-button");
const exportButton = document.getElementById("export-button");
const deleteButton = document.getElementById("delete-button");
const csfrToken = document.head.querySelector("[name~=csrf-token][content]").content;

// Select items
const selectMenu = document.querySelector(".select-menu-infringement");
let cards = document.querySelectorAll("#snapshot-card");
let cardLinks = document.querySelectorAll(".card-trip-link");
let checkBoxes = document.querySelectorAll(".card-trip-checkbox");
let checkCards = document.querySelectorAll(".card-trip-checkcard");
let selectedText = document.querySelectorAll(".selected-text span");
const selectAllButton = document.getElementById("select-button");
const deselectAllButton = document.getElementById("deselect-button");
const invertSelectionButton = document.getElementById("invert-button");
let numberOfSelected = 0;

if (selectTimer != null) {




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

  const updateExportAndDeleteButton = () => {
    if (numberOfSelected === 0 || numberOfSelected === checkBoxes.length) {
      exportButton.innerText = `Export All`;
      deleteButton.innerText = `Delete All`;
    } else {
      exportButton.innerText = `Export (${numberOfSelected})`
      deleteButton.innerText = `Delete (${numberOfSelected})`
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
      cards[i].classList.remove("card-trip");
      cards[i].classList.add("card-trip-noclick");
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
        cards[i].classList.remove("card-trip-noclick");
        cards[i].classList.add("card-trip");
        checkCards[i].style.visibility = null;
      }
      hideSelectMenu();
    }
  }

  const cardClickOn = (event) => {
    for (let i = 0; i < cards.length; i += 1) {
      cards[i].classList.remove("card-trip");
      cards[i].classList.add("card-trip-noclick");
    }
  }

  const cardClickOff = (event) => {
    let checkFlag = false
    for (let i = 0; i < checkBoxes.length; i += 1) {
      if (checkBoxes[i].dataset.checked === "true") {
        checkFlag = true;
        break;
      }
    }
    if (checkFlag === false) {
      for (let i = 0; i < cards.length; i += 1) {
        cards[i].classList.remove("card-trip-noclick");
        cards[i].classList.add("card-trip");
      }
    }
  }

  const checkBoxClick = (event) => {
    event.preventDefault();
    if (event.target.parentElement.dataset.checked === "false")  {// innerHTML.includes("fa-square")) {
      event.target.parentElement.dataset.checked = "true";
      numberOfSelected += 1;
      updateSelectedCount();
      updateExportAndDeleteButton();
      showCheckCards();
      showSelectMenu();
      event.target.parentElement.innerHTML = '<i class="far fa-check-square"></i>';
    } else {
      event.target.parentElement.dataset.checked = "false";
      numberOfSelected -= 1;
      updateSelectedCount();
      updateExportAndDeleteButton();
      hideCheckCards();
      event.target.parentElement.innerHTML = '<i class="far fa-square"></i>';
    }
  }

  const cardLinkClick = (event) => {
    if (numberOfSelected > 0) {
      event.preventDefault();
    }
  }

  const selectAll = (event) => {
    for (let i = 0; i < checkBoxes.length; i += 1) {
      checkBoxes[i].dataset.checked = "true";
      checkBoxes[i].innerHTML = '<i class="far fa-check-square"></i>';
    }
    numberOfSelected = checkBoxes.length;
    updateSelectedCount();
    updateExportAndDeleteButton();
  }

  const deselectAll = (event) => {
    for (let i = 0; i < checkBoxes.length; i += 1) {
      checkBoxes[i].dataset.checked = "false";
      checkBoxes[i].innerHTML = '<i class="far fa-square"></i>';
      checkCards[i].style.visibility = null;
    }
    numberOfSelected = 0;
    cardClickOff(null);
    updateSelectedCount();
    updateExportAndDeleteButton();
    hideSelectMenu();
  }

  const invertSelection = (event) => {
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
      cardClickOff(null);
    }
    hideCheckCards();
    updateSelectedCount();
    updateExportAndDeleteButton();
  }

  for (let i = 0; i < checkBoxes.length; i += 1) {
    checkBoxes[i].addEventListener("click", checkBoxClick);
    checkBoxes[i].addEventListener("mousedown", cardClickOn);
    checkBoxes[i].addEventListener("mouseup", cardClickOff);
    cardLinks[i].addEventListener("click", cardLinkClick);
  }

  selectAllButton.addEventListener("click", selectAll);

  deselectAllButton.addEventListener("click", deselectAll);

  invertSelectionButton.addEventListener("click", invertSelection);




  selectTimer.addEventListener("change", (event) => {
    Rails.ajax({
      url: "",
      type: "put",
      data: `interval=${selectTimer.value}`,
      success: (data) => { },
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
      success: (data) => { },
      error: (data) => {}
    })
  });

  snapshotButton.addEventListener("click", (event) => {
    snapshotButton.innerText = "Taking Snapshot..."
    snapshotButton.disabled = true;
    Rails.ajax({
      url: "",
      type: "put",
      data: `snapshot=true`,
      success: (data) => { },
      error: (data) => {}
    })
  });

  exportButton.addEventListener("click", (event) => {
    exportButton.innerText = "Downloading..."
    exportButton.disabled = true;
    deleteButton.disabled = true;

    Rails.ajax({
      url: window.location.pathname + "/createzip",
      type: "get",
      data: `files=${selectedParametersString()}`,
      success: (data) => { },
      error: (data) => {}
    })
  });

  deleteButton.addEventListener("click", (event) => {
    deleteButton.innerText = "Deleting..."
    deleteButton.disabled = true;
    exportButton.disabled = true;

    Rails.ajax({
      url: window.location.pathname + "/deletesnapshots",
      type: "get",
      data: `files=${selectedParametersString()}`,
      success: (data) => { },
      error: (data) => {}
    })

    for (let i = 0; i < checkBoxes.length; i += 1) {
      if (checkBoxes[i].dataset.checked === "true") {
        cards[i].parentNode.removeChild(cards[i]);
      }
    }

    cards = document.querySelectorAll("#snapshot-card");
    cardLinks = document.querySelectorAll(".card-trip-link");
    checkBoxes = document.querySelectorAll(".card-trip-checkbox");
    checkCards = document.querySelectorAll(".card-trip-checkcard");
    selectedText = document.querySelectorAll(".selected-text span");

    for (let i = 0; i < checkBoxes.length; i += 1) {
      checkBoxes[i].dataset.checked = "false";
      checkBoxes[i].innerHTML = '<i class="far fa-square"></i>';
      checkCards[i].style.visibility = null;
    }

    numberOfSelected = 0;
    cardClickOff(null);
    updateSelectedCount();
    hideSelectMenu();
  });

  setInterval(function() {
    const snapshotCards = document.querySelectorAll("#snapshot-card");
    Rails.ajax({
      url: window.location.pathname + "/refresh",
      type: "get",
      dataType: "script",
      data: `snapshots=${snapshotCards.length}`,
      success: (data) => {
        cards = document.querySelectorAll("#snapshot-card");
        cardLinks = document.querySelectorAll(".card-trip-link");
        checkBoxes = document.querySelectorAll(".card-trip-checkbox");
        checkCards = document.querySelectorAll(".card-trip-checkcard");
        selectedText = document.querySelectorAll(".selected-text span");
        for (let i = 0; i < checkBoxes.length; i += 1) {
          checkBoxes[i].addEventListener("click", checkBoxClick);
          checkBoxes[i].addEventListener("mousedown", cardClickOn);
          checkBoxes[i].addEventListener("mouseup", cardClickOff);
          cardLinks[i].addEventListener("click", cardLinkClick);
        }
      },
      error: (data) => {}
    })
  }, 5000);







}

