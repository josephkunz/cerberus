function showHide(event) {
    var span = document.getElementsByClassName("close")[0];
    var form = document.getElementById("show-form");
    var button = document.getElementById("form_button");
    button.classList.add("disabled");
    form.style.display = "block";
    span.onclick = function() {
      form.style.display = "none";
      button.classList.remove("disabled");
    };
    // Do not uncomment - we will use it later!!!
    // window.onclick = function(event) {
    //   if (event.target == form) {
    //     form.style.display = "none";
    //     button.classList.add("enabled");
    //   }
    // };
}
