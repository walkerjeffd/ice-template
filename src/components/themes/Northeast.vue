<template>
  <ice-feature-container v-if="selected" @close="$emit('close')">
    <template v-slot:title>
      Selected Feature: {{selected.id}}
    </template>

    <div v-if="dataset">
      <ice-feature-box>
        <template v-slot:title>Numeric Variables</template>
        <v-list dense>
          <v-list-item v-for="variableId in tables.num.fields" :key="variableId">
            <v-list-item-content class="align-start" width="20">{{ variableById(variableId).label }}:</v-list-item-content>
            <v-list-item-content class="align-end">{{ variableFormatter(variableId)(dataset[variableId]) }} {{ variableById(variableId).units }}</v-list-item-content>
          </v-list-item>
        </v-list>
      </ice-feature-box>
      <ice-feature-box>
        <template v-slot:title>Categorical Variables</template>
        <v-list dense>
          <v-list-item v-for="variableId in tables.cat.fields" :key="variableId">
            <v-list-item-content class="align-start" width="20">{{ variableById(variableId).label }}:</v-list-item-content>
            <v-list-item-content class="align-end">{{ variableFormatter(variableId)(dataset[variableId]) }}</v-list-item-content>
          </v-list-item>
        </v-list>
      </ice-feature-box>
    </div>
    <div v-else>
      Loading...
    </div>
  </ice-feature-container>
</template>

<script>
import themeSelect from '@/mixins/themeSelect'

export default {
  name: 'Northeast',
  mixins: [themeSelect],
  data () {
    return {
      tables: {
        num: {
          fields: [
            'variable1',
            'variable2'
          ]
        },
        cat: {
          fields: [
            'variable3'
          ]
        }
      }
    }
  }
}
</script>
