<script setup>
import Sidebar from '@/components/admin/Sidebar.vue'
</script>

<template>
  <div class="admin-root grid-shell">
    <aside class="sticky-aside">
      <Sidebar />
    </aside>
    <main class="scroll-content">
      <div class="page-container">
        <RouterView />
      </div>
    </main>
  </div>
</template>

<style scoped>
/* Admin variables，only in admin-root */
.admin-root{
  --sidebar-w: 240px;
  --page-max-w: 1120px;
  --line: #e5e7eb;
  --bg: #fff;
}

.grid-shell{
  display: grid;
  grid-template-columns: var(--sidebar-w) 1fr;
  height: 100vh;
  background: var(--bg);
}

.sticky-aside{
  position: sticky;
  top: 0;
  align-self: start;   /* sticky in grid */
  height: 100vh;
  overflow: auto;
  border-right: 1px solid var(--line);
  background: #fff;
}

.scroll-content{
  min-width: 0;        /* avoid overflow */
  overflow: auto;
  background: #fff;
}

.page-container{
  max-width: var(--page-max-w);
  margin: 0 auto;
  padding: 24px;
}
</style>
