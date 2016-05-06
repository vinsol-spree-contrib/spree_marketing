function CampaignSyncFlashHandler(targets) {
  this.targets = targets;
}

CampaignSyncFlashHandler.prototype.init = function() {
  this.bindEvents();
};

CampaignSyncFlashHandler.prototype.bindEvents = function() {
  $(document).on("ajaxSuccess", function(event, response) {
    show_flash("success", JSON.parse(response.responseText).flash);
  });
};

$(function() {
  campaign_sync_flash_handler = new CampaignSyncFlashHandler($(".campaign_sync"));
  campaign_sync_flash_handler.init();
});
