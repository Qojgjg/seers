<script lang="ts">
  import inf from "./assets/inf.gif"

  export let principal = ""
  export let signIn
  export let label = "Submit"
  export let execute = () => {
    return { ok: null }
  }

  let processing = false
  let errorResponse = ""
  let resp = {}
</script>

{#if principal === ""}
  <div style="display:flex; text-align:end; justify-content:end; flex-grow: 1">
    <button class="btn-grad" style="background: black" on:click={signIn}
      >{label}</button
    >
  </div>
{:else if processing}
  <div style="display:flex; text-align:end; justify-content:end; flex-grow: 1">
    <button
      on:click={() => 0}
      class="btn-grad"
      style="width: 100px; overflow:hidden; background: black"
    >
      <img
        src={inf}
        alt="inf"
        style="width: 150px; height: 400%; margin: -100%;"
      />
    </button>
  </div>
{:else}
  <div style="display:flex; text-align:end; justify-content:end; flex-grow: 1">
    <button
      class="btn-grad"
      style="background: black"
      on:click={async () => {
        processing = true
        resp = await execute()
        processing = false
        if ("err" in resp) {
          errorResponse = resp["err"]
        }
      }}>{label}</button
    >
    <div style="text-align:end;color:red">
      {errorResponse}
    </div>
  </div>
{/if}
