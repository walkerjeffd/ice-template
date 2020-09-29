<template>
  <div>
    <v-toolbar dense dark color="primary">
      <h3 class="headline mb-0"><slot name="title"></slot></h3>
      <v-spacer></v-spacer>
      <v-btn icon color="white" @click="$emit('close')">
        <v-icon>mdi-close</v-icon>
      </v-btn>
    </v-toolbar>
    <v-card-text>
      <div v-if="loading" class="title">
        <div class="title my-4">
          <v-progress-circular
            :size="30"
            :width="5"
            color="primary"
            indeterminate
            class="mx-4"
          ></v-progress-circular>
          Loading
        </div>
      </div>
      <div v-else-if="error">
        <v-alert type="error" outlined prominent>
          <div class="title">Server Error</div>
          Failed to get dataset for selected feature.
        </v-alert>
      </div>
      <slot></slot>
    </v-card-text>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'IceFeatureContainer',
  props: ['loading', 'error'],
  computed: {
    ...mapGetters(['theme'])
  }
}
</script>
