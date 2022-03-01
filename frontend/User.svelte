<script lang="ts">
  import Header from "./Header.svelte"

  export let auth
  export let principal

  console.log(principal)
</script>

<Header />

<div class="UserBody">Data for User: {principal}</div>

<style global>
  .UserBody {
    display: flex;
    justify-content: center;
  }
</style>
