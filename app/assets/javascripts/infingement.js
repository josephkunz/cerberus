const selectTimer =  document.getElementById("select-timer");
const playButton = document.getElementById("play-button");
const snapshotButton = document.getElementById("snapshot-button");
const csfrToken = document.head.querySelector("[name~=csrf-token][content]").content;

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
}
