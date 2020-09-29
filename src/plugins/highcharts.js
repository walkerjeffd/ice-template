import Vue from 'vue'
import HighchartsVue from 'highcharts-vue'
import Highcharts from 'highcharts'
import more from 'highcharts/highcharts-more'

more(Highcharts)

Highcharts.setOptions({
  lang: {
    thousandsSep: ','
  }
});

// Allow negative values on log-scale
// https://jsfiddle.net/gh/get/library/pure/highcharts/highcharts/tree/master/samples/highcharts/yaxis/type-log-negative/
(function (H) {
  // Pass error messages
  H.Axis.prototype.allowNegativeLog = true

  // Override conversions
  H.Axis.prototype.log2lin = function (num) {
    const isNegative = num < 0
    let adjustedNum = Math.abs(num)
    let result
    if (adjustedNum < 10) {
      adjustedNum += (10 - adjustedNum) / 10
    }
    result = Math.log(adjustedNum) / Math.LN10
    return isNegative ? -result : result
  }
  H.Axis.prototype.lin2log = function (num) {
    const isNegative = num < 0
    const absNum = Math.abs(num)
    let result = Math.pow(10, absNum)
    if (result < 10) {
      result = (10 * (result - 1)) / (10 - 1)
    }
    return isNegative ? -result : result
  }
}(Highcharts))

Vue.use(HighchartsVue)
