<script lang="ts">
  import inf from "./assets/inf.gif"

  export let principal = ""
  export let signIn
  export let label = "Submit"
  export let execute = () => {}
  export let processing = false
</script>

<div style="display:flex; text-align:end; justify-content:end; flex-grow: 1">
  <button
    class="btn-grad"
    style={`${
      processing
        ? "width: 100px; overflow:hidden; background: black"
        : "background:black"
    }`}
    on:click={() => {
      if (principal === "") signIn()
      else if (!processing) execute()
    }}
  >
    {#if !processing}
      {label}
    {/if}
    <img
      src={inf}
      alt="inf"
      style={`${
        processing
          ? "width: 150px; height: 400%; margin: -100%;"
          : "display: none"
      }`}
    />
  </button>
</div>
