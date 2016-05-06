function AjaxHandler(targets) {
  this.targets = targets;
}

AjaxHandler.prototype.init = function() {
  this.bindEvents();
};

AjaxHandler.prototype.bindEvents = function() {
  var _this = this;
  $.each(_this.targets, function(index, target) {
    var $target = $(target);
    $target.unbind('click').on('click', function() {
      var data = $target.data();
      _this.sendRequest($target, data);
    });
  });
};

AjaxHandler.prototype.sendRequest = function($target, data) {
  var _this = this;
  $.ajax({
    url: data.url,
    dataType: "JSON",
    method: data.method,
    success: function(response) {
      _this.handleSuccessResponse(response);
    },
    error: function(response) {
      _this.handleErrorResponse(response);
    }
  });
};

AjaxHandler.prototype.handleErrorResponse = function(response) {
  show_flash('error', response.flash);
};

AjaxHandler.prototype.handleSuccessResponse = function(response) {
  show_flash('success', response.flash);
}

$(function (){
  var ajaxHandler = new AjaxHandler($('.ajax_handler'));
  ajaxHandler.init();
});
