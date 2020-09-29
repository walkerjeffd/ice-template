<template>
  <v-app>
    <v-app-bar dense app dark absolute v-if="$vuetify.breakpoint.mdAndUp">
      <v-toolbar-title class="headline">
        Interactive Catchment Explorer | Template
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn text medium class="mx-2" @click="dialogs.welcome = true">
        <v-icon small left>mdi-home</v-icon> Welcome
      </v-btn>
      <v-btn text medium class="mx-2" @click="dialogs.contact = true">
        <v-icon small left>mdi-email</v-icon> Contact
      </v-btn>
    </v-app-bar>
    <v-app-bar app dense clipped-left dark absolute v-else>
      <v-toolbar-title class="subheading">
        <span>ICE | Template</span>
      </v-toolbar-title>
    </v-app-bar>

    <v-content v-if="$vuetify.breakpoint.mdAndUp">
      <IceMap :basemaps="map.basemaps" :center="[38, -98]" :zoom="5">
        <IceMapLayer
          name="points"
          set-bounds
          :layer="layer"
          :getFill="getFill"
          :getValue="getValue"
          :selected="feature.selected"
          @click="selectFeature">
        </IceMapLayer>
      </IceMap>
      <v-container fluid fill-height class="align-stretch py-0">
        <v-row>
          <v-col>
            <v-card width="500">
              <v-tabs
                v-model="tabs.active"
                class="ice-tabs-main"
                background-color="primary"
                dark
                slider-color="white">
                <v-tab ripple>
                  Dataset
                </v-tab>
                <v-tab ripple :disabled="!theme">
                  Map Variable
                </v-tab>
                <v-tab ripple :disabled="!theme">
                  Crossfilters
                </v-tab>
                <v-spacer></v-spacer>
                <v-btn icon small @click="collapse.tabs = !collapse.tabs" class="align-self-center mr-1">
                  <v-icon small v-if="!collapse.tabs">mdi-menu-up</v-icon>
                  <v-icon small v-else>mdi-menu-down</v-icon>
                </v-btn>
                <v-tab-item transition="false" reverse-transition="false">
                  <v-card class="ice-card elevation-10 pb-0" ref="dataset" v-if="!collapse.tabs">
                    <v-card-text v-if="theme" class="px-3">
                      <div class="title font-weight-bold grey--text text--darken-4">
                        <span v-if="theme">{{ theme.label }}</span>
                        <span v-else-if="error.theme">Failed to load dataset</span>
                        <span v-else>None</span>
                      </div>
                      <div class="body-1" v-if="theme">{{ theme.description }}</div>
                    </v-card-text>
                    <v-card-text v-else-if="error.theme">
                      <v-alert type="error" outlined class="mb-0">
                        <strong>Failed to load dataset</strong><br>
                        Try another dataset or <a @click="dialogs.contact=true">contact us</a> if the problem persists.
                      </v-alert>
                    </v-card-text>
                    <v-card-text v-else>
                      <v-alert type="info" outlined class="mb-0">
                        <strong>No dataset has been loaded</strong><br>
                        Open the Dataset Browser to load a dataset.
                      </v-alert>
                    </v-card-text>
                    <v-divider></v-divider>
                    <v-card-actions class="pa-3">
                      <v-btn small outlined text color="primary" @click="dialogs.theme = true">
                        <v-icon left small>mdi-folder-open</v-icon> Dataset Browser
                      </v-btn>
                      <v-spacer></v-spacer>
                      <v-btn small outlined text color="primary" v-if="theme" @click="dialogs.download = true">
                        <v-icon left small>mdi-download</v-icon> Download
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-tab-item>
                <v-tab-item transition="false" reverse-transition="false">
                  <v-card v-show="!collapse.tabs" v-if="theme">
                    <v-card-text class="pb-2">
                      <v-autocomplete
                        label="Select variable..."
                        :items="mapVariables"
                        v-model="variable"
                        return-object
                        dense
                        outlined
                        item-value="id"
                        item-text="label"
                        :menu-props="{ closeOnClick: false, closeOnContentClick: false, openOnClick: false, maxHeight: 400 }"
                        class="mb-4 mt-2"
                        hide-details>
                        <template v-slot:item="{ item }">
                          <v-list-item-content class="pl-3 body-2" v-html="item.label"></v-list-item-content>
                          <v-tooltip right max-width="600">
                            <template v-slot:activator="{ on }">
                              <v-icon v-on="on" small color="grey lighten-1">mdi-information</v-icon>
                            </template>
                            {{ item.description }}
                          </v-tooltip>
                        </template>
                      </v-autocomplete>
                    </v-card-text>
                  </v-card>
                </v-tab-item>
                <v-tab-item transition="false" reverse-transition="false">
                  <v-card v-show="!collapse.tabs" v-if="theme">
                    <v-card-text class="pb-2">
                      <v-autocomplete
                        :items="filterVariables"
                        v-model="filters"
                        multiple
                        dense
                        return-object
                        item-value="id"
                        item-text="label"
                        chips
                        small-chips
                        outlined
                        class="mb-4 mt-2"
                        hide-details
                        deletable-chips
                        clearable
                        label="Select crossfilter variable(s)...">
                        <template v-slot:item="data">
                          <v-list-item-action>
                            <v-checkbox small :value="data.attrs.inputValue"></v-checkbox>
                          </v-list-item-action>
                          <v-list-item-content class="body-2" v-html="data.item.label"></v-list-item-content>
                        </template>
                      </v-autocomplete>
                      <ice-filter v-for="variable in filters" :key="variable.id" :variable="variable" @close="removeFilter(variable)"></ice-filter>
                    </v-card-text>
                  </v-card>
                </v-tab-item>
              </v-tabs>
            </v-card>
          </v-col>
          <v-col>
            <ice-legend-box v-if="theme && variable" :collapse="collapse.legend" :counts="counts" @collapse="collapse.legend = !collapse.legend"></ice-legend-box>
          </v-col>
        </v-row>
      </v-container>
      <v-navigation-drawer
        :value="!!feature.selected"
        right
        temporary
        fixed
        hide-overlay
        stateless
        width="500"
        class="mt-0">
        <component v-if="theme" :is="theme.id" :selected="feature.selected" @close="selectFeature()"></component>
      </v-navigation-drawer>
    </v-content>

    <v-content v-else>
      <v-card>
        <v-card-text class="mt-4 black--text">
          <div class="text-center mb-8">
            <h2 class="headline">Welcome to the Interactive Catchment Explorer</h2>
          </div>

          <div class="mt-8">
            <v-alert type="error" class="my-8" outlined prominent>
              <div class="title">This site is not designed for mobile devices.</div>
              Please use a laptop or desktop with a larger screen size (>960px wide).
            </v-alert>
          </div>

          <v-divider class="mb-4"></v-divider>

          <h4 class="title">Project Background</h4>
          <p class="body-1">
            Lorem ipsum dolor sit amet consectetur, adipisicing elit. Dicta, unde qui. Illo ea tempora eveniet ab voluptas esse illum quae sed ex exercitationem modi expedita veniam natus, explicabo consectetur aut.
          </p>

          <h4 class="title">About the application</h4>
          <p class="body-1">
            This application provides a set of interactive data visualization tools to explore environmental datasets and model outputs.
            The purpose of this tool is to help stakeholders, decision makers and other interested users
            access these datasets and develop a better understanding of spatial and temporal patterns.
          </p>
          <p class="body-1">
            ICE was developed by <a href="https://walkerenvres.com" target="_blank">Walker Environmental Research</a>
            as part of the <a href="https://ecosheds.org" target="_blank">Spatial Hydro-Ecological Decision System (SHEDS)</a>.
          </p>
        </v-card-text>
      </v-card>
    </v-content>

    <!-- welcome -->
    <v-dialog
      v-model="dialogs.welcome"
      max-width="1000"
      v-if="$vuetify.breakpoint.mdAndUp"
      scrollable>
      <v-card>
        <v-toolbar dark dense color="primary">
          <v-toolbar-title><v-icon left>mdi-home</v-icon> Welcome</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn icon @click="dialogs.welcome = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-toolbar>

        <v-card-text class="mt-4 black--text">
          <div class="text-center mb-8">
            <h2 class="headline">Welcome to the Interactive Catchment Explorer Template</h2>
          </div>

          <div class="text-center my-8">
            <div class="mt-8">
              <v-btn
                color="success"
                x-large
                @click="dialogs.welcome = false; dialogs.theme = true">
                Get Started <v-icon>mdi-chevron-double-right</v-icon>
              </v-btn>
            </div>
          </div>

          <v-divider class="mb-4"></v-divider>

          <h4 class="title">Project Background</h4>
          <p class="body-1">
            Lorem ipsum dolor sit amet consectetur adipisicing elit. Quasi reprehenderit perferendis eveniet hic, eligendi omnis facere possimus dignissimos laborum commodi tempora eos vel qui aliquam, id ad rerum aspernatur nostrum!
          </p>

          <h4 class="title">About the application</h4>
          <p class="body-1">
            This application provides a set of interactive data visualization tools to explore environmental datasets and model outputs.
            The purpose of this tool is to help stakeholders, decision makers and other interested users
            access these datasets and develop a better understanding of spatial and temporal patterns.
          </p>
          <p class="body-1">
            ICE was developed by <a href="https://walkerenvres.com" target="_blank">Walker Environmental Research</a>
            as part of the <a href="https://ecosheds.org" target="_blank">Spatial Hydro-Ecological Decision System (SHEDS)</a>.
          </p>
        </v-card-text>

        <v-divider class="mb-4"></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            text
            @click="dialogs.welcome = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- contact -->
    <v-dialog
      v-model="dialogs.contact"
      max-width="600"
      scrollable>
      <v-card>
        <v-toolbar dark color="primary">
          <v-toolbar-title><v-icon left>mdi-email</v-icon> Contact Information</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn icon @click="dialogs.contact = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-toolbar>

        <v-card-text class="mt-8 black--text">
          Lorem ipsum dolor sit amet consectetur adipisicing elit. Ipsum voluptates placeat eos maiores dolorem fugiat, rerum cumque. Molestiae libero id tempora voluptatibus harum asperiores porro assumenda aliquam minus, officiis dolorem?
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            text
            @click="dialogs.contact = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- download -->
    <v-dialog
      v-model="dialogs.download"
      max-width="1000"
      scrollable>
      <v-card>
        <v-toolbar dark color="primary">
          <v-toolbar-title><v-icon left>mdi-download</v-icon> Download</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn icon @click="dialogs.download = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-toolbar>

        <v-card-text class="my-4 black--text" v-if="theme">
          <v-container>
            <v-row>
              <v-col class="text-center">
                <h2>Complete Dataset</h2>
                <p class="font-italic my-8">Includes all features regardless of any filters that are currently set.</p>
                <v-btn color="success" @click="downloadDataset(false)">
                  <v-icon>mdi-download</v-icon> Complete Dataset (CSV)
                </v-btn>
              </v-col>
              <v-divider vertical></v-divider>
              <v-col class="text-center">
                <h2>Filtered Dataset</h2>
                <p class="font-italic my-8">Includes only features that meet any existing filters.</p>
                <v-btn color="success" @click="downloadDataset(true)">
                  <v-icon>mdi-download</v-icon> Filtered Dataset (CSV)
                </v-btn>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            text
            @click="dialogs.download = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- dataset browser -->
    <v-dialog
      v-model="dialogs.theme"
      max-width="1200"
      scrollable>
      <v-card>
        <v-toolbar dark color="primary">
          <v-toolbar-title>Dataset Browser</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn icon @click="dialogs.theme = false">
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </v-toolbar>

        <v-card-text class="pl-0">
          <v-row justify="space-between">
            <v-col sm="4">
              <v-treeview
                v-model="themes.selected"
                :active.sync="themes.active"
                :open.sync="themes.open"
                :items="themes.options"
                activatable
                return-object
                open-on-click
                dense
                open-all>
                <template v-slot:prepend="{ item, open }">
                  <v-icon v-if="item.children">
                    {{ open ? 'mdi-folder-open' : 'mdi-folder' }}
                  </v-icon>
                  <v-icon v-else>
                    {{ 'mdi-table' }}
                  </v-icon>
                </template>
                <template v-slot:label="{ item }">
                  <span v-if="item.children" class="subtitle-1">
                    {{item.name}}
                  </span>
                  <span v-else>
                    {{item.name}}
                  </span>
                </template>
              </v-treeview>
            </v-col>
            <v-divider vertical></v-divider>
            <v-col>
              <div v-for="theme in themes.active" :key="theme.id" class="pt-4 black--text">
                <h2 class="mb-2">{{theme.label}}</h2>
                <p>{{theme.description}}</p>
                <div class="text-center my-8">
                  <v-btn large color="green" dark @click="selectTheme(theme)" :loading="loading.theme">
                    Load Dataset
                    <v-icon right>mdi-chevron-double-right</v-icon>
                  </v-btn>
                </div>
              </div>

              <div class="pt-4 black--text" style="width:100%" v-if="themes.active.length === 0">
                <v-alert color="success" prominent outlined icon="mdi-chevron-left">
                  Select a dataset from the list.
                </v-alert>

                <h4 class="title">About</h4>
                <p class="body-2">
                  Use the Dataset Browser to load a specific dataset into the application. Only one dataset can be loaded at any given time.
                </p>
              </div>
            </v-col>
          </v-row>
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="primary"
            text
            @click="dialogs.theme = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-app>
</template>

<script>
import { mapGetters } from 'vuex'

import IceMap from '@/components/IceMap'
import IceMapLayer from '@/components/IceMapLayer'
import IceFilter from '@/components/IceFilter'
import IceLegendBox from '@/components/IceLegendBox'

import Northeast from '@/components/themes/Northeast'
import Northwest from '@/components/themes/Northwest'

import { getValueById, getFilteredCount, getTotalCount } from '@/lib/crossfilter'
import themes from '@/assets/themes'
import evt from '@/lib/events'
import { groupVariables } from '@/lib/utils'
import { downloadDataset } from '@/lib/download'
import VariableMixin from '@/mixins/variable'
import ColorMixin from '@/mixins/color'

export default {
  name: 'App',
  mixins: [VariableMixin, ColorMixin],
  components: {
    IceMap,
    IceMapLayer,
    IceFilter,
    IceLegendBox,
    Northeast,
    Northwest
  },
  data: () => ({
    debug: process.env.NODE_ENV === 'development',
    // debug: false,
    collapse: {
      dataset: false,
      tabs: false,
      legend: false,
      debug: false
    },
    tabs: {
      active: 0
    },
    filters: [],
    rightSidebar: {
      open: true
    },
    dialogs: {
      theme: false,
      welcome: true,
      contact: false,
      help: false,
      download: false
    },
    loading: {
      theme: false
    },
    error: {
      theme: null
    },
    themes: {
      active: [],
      selected: [],
      open: themes.map(d => d.id),
      options: themes
    },
    feature: {
      selected: null
    },
    counts: {
      total: 0,
      filtered: 0
    },
    map: {
      basemaps: [
        {
          name: 'ESRI World Imagery',
          visible: true,
          url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
        },
        {
          name: 'USGS Imagery',
          visible: false,
          url: 'https://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/tile/{z}/{y}/{x}',
          attribution: '<a href="http://www.doi.gov">U.S. Department of the Interior</a> | <a href="http://www.usgs.gov">U.S. Geological Survey</a> | <a href="http://www.usgs.gov/laws/policies_notices.html">Policies</a>'
        },
        {
          name: 'USGS Topo',
          visible: false,
          url: 'https://basemap.nationalmap.gov/ArcGIS/rest/services/USGSTopo/MapServer/tile/{z}/{y}/{x}',
          attribution: '<a href="http://www.doi.gov">U.S. Department of the Interior</a> | <a href="http://www.usgs.gov">U.S. Geological Survey</a> | <a href="http://www.usgs.gov/laws/policies_notices.html">Policies</a>'
        },
        {
          name: 'USGS Hydrography',
          visible: false,
          url: 'https://basemap.nationalmap.gov/arcgis/rest/services/USGSHydroCached/MapServer/tile/{z}/{y}/{x}',
          attribution: '<a href="http://www.doi.gov">U.S. Department of the Interior</a> | <a href="http://www.usgs.gov">U.S. Geological Survey</a> | <a href="http://www.usgs.gov/laws/policies_notices.html">Policies</a>'
        },
        {
          name: 'OpenStreetMap',
          visible: false,
          url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        },
        {
          name: 'No Basemap',
          visible: false,
          url: '',
          attribution: ''
        }
      ]
    },
    legendSettings: false
  }),
  computed: {
    ...mapGetters(['theme', 'variables', 'layer', 'colorScheme', 'colorInvert']),
    variable: {
      get () {
        return this.$store.getters.variable
      },
      set (value) {
        return this.$store.dispatch('setVariable', value)
      }
    },
    mapVariables () {
      return groupVariables(this.variables.filter(d => d.map))
    },
    filterVariables () {
      return groupVariables(this.variables.filter(d => d.filter))
    }
  },
  mounted () {
    // if (!this.theme) this.dialogs.welcome = true
    evt.$on('xf:filter', this.updateCounts)
  },
  beforeDestroy () {
    evt.$off('xf:filter', this.updateCounts)
  },
  watch: {
    variable () {
      this.variable && evt.$emit('map:render')
    }
  },
  methods: {
    async goDebug () {
      const themes = [
        ...this.themes.options[0].children,
        ...this.themes.options[1].children
      ]

      const loadVariable = (variable) => {
        return new Promise((resolve) => {
          this.filters = [variable]
          this.setVariableById(variable.id)
          setTimeout(() => {
            resolve(true)
          }, 2000)
        })
      }

      for (let iTheme = 0; iTheme < themes.length; iTheme++) {
        console.log(`theme: ${themes[iTheme].id}`)
        await this.selectTheme(themes[iTheme])
          .then(() => {
            return new Promise(async (resolve) => {
              const variables = this.variables.filter(d => d.filter)
              await loadVariable(variables[0])
              for (let i = 1; i < variables.length; i++) {
                console.log(`variable: ${variables[i].id}`)
                await loadVariable(variables[i])
              }
              resolve(true)
            })
          })
      }
    },
    updateCounts () {
      this.counts.total = getTotalCount()
      this.counts.filtered = getFilteredCount()
    },
    selectTheme (theme) {
      this.loading.theme = true
      this.error.theme = null

      return this.clearTheme()
        .then(() => this.$store.dispatch('loadTheme', theme))
        .then((theme) => {
          this.error.theme = null
          this.updateCounts()
        })
        .catch((err) => {
          console.error(err)
          this.error.theme = 'Failed to load theme'
        })
        .finally(() => {
          evt.$emit('theme:set')
          this.loading.theme = false
          this.dialogs.theme = false
        })
    },
    clearTheme () {
      this.selectFeature()
      this.clearFilters()
      return this.$store.dispatch('clearTheme')
        .then(() => this.updateCounts())
    },
    selectFeature (feature) {
      if (!feature || this.feature.selected === feature) {
        this.feature.selected = null
      } else {
        this.feature.selected = feature
        // TODO: fetch drainage area layer
      }
    },
    getValue (feature) {
      return getValueById(feature.id)
    },
    getFill (feature) {
      const value = this.getValue(feature)
      return value ? this.colorScale(this.variableScale(value.mean)) : null
    },
    removeFilter (variable) {
      this.filters.splice(this.filters.findIndex(v => v === variable), 1)
    },
    clearFilters () {
      this.filters = []
    },
    setVariableById (id) {
      const variable = this.$store.getters.variableById(id)
      if (!variable) return
      this.variable = variable
      this.updateCounts()
    },
    downloadDataset (filtered) {
      downloadDataset(filtered, this.theme)
        .catch((err) => alert(`Failed to download dataset\n\n${err}`))
    }
  }
}
</script>

<style>
.v-dialog__content.v-dialog__content--active {
  align-items: start;
}
/* .v-tabs.ice-tabs-main > .v-window > .v-window__container {
  max-height: calc(100vh);
  overflow-y: auto;
} */
.v-toolbar__content {
  padding-left: 12px;
  padding-right: 12px;
}
</style>
