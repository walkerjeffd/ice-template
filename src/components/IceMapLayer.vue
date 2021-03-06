<script>
import { mapGetters } from 'vuex'
import * as d3 from 'd3'
import d3Tip from 'd3-tip'
import * as L from 'leaflet'

import evt from '@/lib/events'
import variableMixin from '@/mixins/variable'

export default {
  name: 'IceMapLayer',
  mixins: [variableMixin],
  props: {
    name: {
      type: String,
      required: true
    },
    layer: {
      type: Object,
      required: false
    },
    setBounds: {
      type: Boolean,
      required: false,
      default: false
    },
    getFill: {
      type: Function,
      required: false,
      default: () => 'red'
    },
    getValue: {
      type: Function,
      required: false,
      default: () => null
    },
    selected: {
      type: Object,
      required: false,
      default: null
    }
  },
  data () {
    return {
      data: null,
      container: null,
      tip: d3Tip()
        .attr('class', 'd3-tip')
    }
  },
  computed: {
    ...mapGetters(['variable', 'themeType', 'theme']),
    path () {
      const map = this.map
      function projectPoint (x, y) {
        const point = map.latLngToLayerPoint(new L.LatLng(y, x))
        this.stream.point(point.x, point.y)
      }
      const transform = d3.geoTransform({ point: projectPoint })
      return d3.geoPath().projection(transform) // .pointRadius(this.pointRadius)
    },
    map () {
      return this.$parent.map
    },
    disableClick () {
      return this.$parent.disableClick
    },
    zoomLevel () {
      return this.$parent.zoomLevel
    },
    pointRadius () {
      return this.zoomLevel - 2
    }
  },
  mounted () {
    // console.log(`map-layer(${this.name}):mounted`)
    evt.$on('map:zoom', this.render)
    evt.$on('map:render', this.renderFill)
    evt.$on('theme:set', this.loadLayer)

    this.container = this.$parent.svg.select('g').append('g').attr('class', 'ice-map-layer')
    this.container.call(this.tip)

    if (this.theme) {
      this.loadLayer()
    }

    this.setTipHtml()
    this.render()
  },
  beforeDestroy () {
    // console.log(`map-layer(${this.name}):beforeDestroy`)
    evt.$off('map:zoom', this.render)
    evt.$off('map:render', this.renderFill)
    evt.$off('theme:set', this.loadLayer)
    this.tip.destroy()
    this.container.selectAll('*').remove()
    this.container.remove()
    this.data = null
  },
  watch: {
    variable () {
      // console.log(`map-layer(${this.name}):watch variable`)
      this.setTipHtml()
    },
    theme () {
      console.log(`map-layer(${this.name}):watch theme`)
      if (!this.layer) return this.clearLayer()
      return this.loadLayer()
    },
    selected () {
      // console.log(`map-layer(${this.name}):watch selected`)
      this.renderSelected()
    }
  },
  methods: {
    setTipHtml () {
      this.tip.html(d => `
        <strong>ID: ${d.id}</strong><br>
        ${this.variable.label}: ${typeof this.getValue(d) === 'object' ? this.valueFormatter(this.getValue(d).mean) + ` ${this.variable.units || ''}` : 'N/A'}
      `)
    },
    loadLayer () {
      // console.log(`map-layer(${this.name}):loadLayer`, this.theme)
      if (!this.theme) return

      this.container
        .selectAll('circle')
        .remove()

      return this.$http.get(`${this.theme.id}/layer.json`)
        .then(response => response.data)
        .then((data) => {
          this.data = Object.freeze(data)
          this.fitBounds()
          this.render()
        })
    },
    clearLayer () {
      this.container
        .selectAll('circle')
        .remove()
    },
    fitBounds () {
      if (!this.data || this.data.features.length === 0) return null

      const lonExtent = d3.extent(this.data.features.map(d => d.geometry.coordinates[0]))
      const latExtent = d3.extent(this.data.features.map(d => d.geometry.coordinates[1]))
      const bbox = [lonExtent, latExtent] // [[xmin, xmax], [ymin, ymax]]
      const bounds = [
        [bbox[1][0], bbox[0][0] - 0.03], // bottomleft
        [bbox[1][1], bbox[0][1] + 0.03] // topright
      ]
      this.map.fitBounds(bounds)
    },
    projectPoint (d) {
      const latLng = new L.LatLng(d.geometry.coordinates[1], d.geometry.coordinates[0])
      return this.map.latLngToLayerPoint(latLng)
    },
    render () {
      // console.log(`map-layer(${this.name}):render`)
      if (!this.data) return

      const vm = this
      const tip = this.tip

      const features = this.data.features || []
      this.container
        .selectAll('circles')
        .remove()

      const circles = this.container
        .selectAll('circle')
        .data(features, d => d.id)

      circles.enter()
        .append('circle')
        .on('click', function (d) {
          !vm.disableClick && vm.$emit('click', d)
          this.parentNode.appendChild(this) // move to front
        })
        .on('mouseenter', function (d) {
          if (!vm.selected) {
            // move to front if nothing selected
            this.parentNode.appendChild(this)
          } else {
            // move to 2nd from front, behind selected
            const lastChild = this.parentNode.lastChild
            this.parentNode.insertBefore(this, lastChild)
          }

          d3.select(this)
            .attr('r', vm.pointRadius * 2)

          tip.show(d, this)
        })
        .on('mouseout', function (d) {
          d3.select(this)
            .attr('r', vm.pointRadius)
          tip.hide(d, this)
        })
        .merge(circles)
        .attr('r', this.pointRadius)
        .each(function (d) {
          const point = vm.projectPoint(d)
          d3.select(this)
            .attr('cx', d => point.x)
            .attr('cy', d => point.y)
        })

      circles.exit().remove()

      this.renderFill()
    },
    renderFill () {
      // console.log(`map-layer(${this.name}):renderFill`)
      this.container
        .selectAll('circle')
        .style('fill', this.getFill)
        .style('display', d => this.getValue(d) && this.getValue(d).count > 0 ? 'inline' : 'none')
    },
    renderSelected () {
      // console.log(`map-layer(${this.name}):renderSelected`)
      this.container
        .selectAll('circle')
        .classed('selected', this.isSelected)
    },
    isSelected (feature) {
      return !!this.selected && this.selected.id === feature.id
    }
  },
  render: function (h) {
    return null
  }
}
</script>

<style>
g.ice-map-layer > circle {
  cursor: pointer;
  pointer-events: visible;
}

g.ice-map-layer > circle.selected {
  stroke-width: 2px;
  stroke: red;
}

.d3-tip {
  line-height: 1;
  padding: 10px;
  background: rgba(255, 255, 255, 0.8);
  color: #000;
  border-radius: 2px;
  pointer-events: none;
  font-family: sans-serif;
  z-index: 1000;
}
</style>
