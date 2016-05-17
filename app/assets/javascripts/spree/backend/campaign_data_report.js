function CampaignDataReport($container, innerData, outerData) {
  this.$container = $container;
  this.innerData = innerData;
  this.outerData = outerData;
}

CampaignDataReport.prototype.init = function() {
  this.fillData();
};

CampaignDataReport.prototype.fillData = function() {
  this.$container.highcharts({
    chart: {
      type: 'pie'
    },
    title: {
      text: 'Email reports for the campaign'
    },
    plotOptions: {
      pie: {
        shadow: true,
        center: ['50%', '50%']
      }
    },
    tooltip: {
      valueSuffix: ''
    },
    series: [{
      name: 'Count',
      data: this.innerData,
      size: '60%',
      dataLabels: {
        formatter: function(){
          return this.point.name;
        },
        distance: -30
      }
    }, {
      name: 'Count',
      data: this.outerData,
      size: '80%',
      innerSize: '60%',
      dataLabels: {
        formatter: function(){
          return this.point.name + ':</b> ' + this.y;
        }
      }
    }]
  });
};
