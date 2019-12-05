const btnPrintSnapshot = document.getElementById("btn-print-snapshot");
const snapshotWindow = document.querySelector(".snapshot-window-snapshots");
const arrowRight = document.querySelector(".arrow-right-snapshots");
const arrowLeft = document.querySelector(".arrow-left-snapshots");

if (btnPrintSnapshot !== null) {
  pathArray = window.location.pathname.split("/");
  let snapshotId = pathArray[pathArray.length - 1];


  btnPrintSnapshot.addEventListener("click", (event) => {
    window.print();
    return false;
  });

  const leftAjax = (event) => {
    let id = document.getElementById("img-snapshots").dataset.arrayid
    Rails.ajax({
      url: window.location.pathname + "/nextsnapshot",
      type: "get",
      data: `image=previous&snapshot_id=${id}`,
      success: (data) => { console.log(data);},
      error: (data) => {}
    });
  }

  const rightAjax = (event) => {
    let id = document.getElementById("img-snapshots").dataset.arrayid
    Rails.ajax({
      url: window.location.pathname + "/nextsnapshot",
      type: "get",
      data: `image=next&snapshot_id=${id}`,
      success: (data) => { },
      error: (data) => {}
    });
  }

  document.addEventListener('keydown', (event) =>  {
    if (event.code === 'ArrowLeft') {
      leftAjax(event);
    }
    if (event.code === 'ArrowRight') {
      rightAjax(event);
    }
  });

  arrowRight.addEventListener('click', rightAjax);
  arrowLeft.addEventListener('click', leftAjax);
}


