<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { ref, onMounted, provide } from 'vue'

// 2 layouts
import AuthLayout from './layouts/AuthLayout.vue'
import AdminLayout from './layouts/AdminLayout.vue'

const route = useRoute()
const CurrentLayout = computed(() => {return route.meta.layout === 'admin' ? AdminLayout : AuthLayout})
</script>

<template>
  <!-- according to meta change layout -->
  <component :is="CurrentLayout">
    <!--  <RouterView/>  -->
  </component>
</template>
