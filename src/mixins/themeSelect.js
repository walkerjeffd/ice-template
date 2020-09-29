import { mapGetters } from 'vuex'
import { format } from 'd3'

import IceFeatureContainer from '@/components/IceFeatureContainer'
import IceFeatureBox from '@/components/IceFeatureBox'

export default {
  props: ['selected'],
  components: {
    IceFeatureContainer,
    IceFeatureBox
  },
  data () {
    return {
      dataset: null,
      loading: true,
      error: false
    }
  },
  computed: {
    ...mapGetters(['theme', 'variableById']),
    values () {
      return this.dataset ? this.dataset.values : []
    }
  },
  mounted () {
    this.updateDataset()
  },
  beforeDestroy () {
    this.clearCharts()
  },
  watch: {
    dataset () {
      this.updateCharts()
    },
    selected () {
      this.updateDataset()
    }
  },
  methods: {
    variableFormatter (id) {
      const variable = this.variableById(id)
      if (variable.type === 'cat') {
        const domain = variable.scale.domain
        const map = new Map(domain.map(d => [d.value, d.label]))
        return (d) => map.get(d)
      }
      return format(variable.formats.value)
    },
    updateDataset () {
      this.loading = true
      this.error = false
      if (!this.selected) {
        this.dataset = null
        return
      }
      this.$http.get(`/${this.theme.id}/features/${this.selected.id}.json`)
        .then((response) => {
          this.dataset = response.data
          this.loading = false
        })
        .catch((err) => {
          console.log(err)
          this.loading = false
          this.error = true
          this.dataset = null
        })
    },
    updateCharts () {
      return null
    },
    clearCharts () {
      if (!this.charts) return
      for (const chart in this.charts) {
        this.charts[chart].series = []
      }
    }
  }
}
