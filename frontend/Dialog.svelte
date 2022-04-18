<script>
  import { getContext } from "svelte"
  export let message
  export let hasForm = false
  export let onCancel = () => {}
  export let onOkay = () => {}

  const { close } = getContext("simple-modal")

  let value
  let onChange = () => {}

  function _onCancel() {
    onCancel()
    close()
  }

  function _onOkay() {
    onOkay(value)
    close()
  }

  $: onChange(value)
</script>

<h3>{message}</h3>

<p>Buying 42 shares of Yes outcome at an average price of 3 &Sigma;.</p>
<p>Total cost is 126 &Sigma;.</p>

<!-- {#if hasForm}
  <input
    type="text"
    bind:value
    on:keydown={(e) => e.which === 13 && _onOkay()}
  />
{/if} -->

<div class="buttons">
  <button class="btn-grad" on:click={_onCancel}> Cancel </button>
  <button class="btn-grad" on:click={_onOkay}> Okay </button>
</div>

<style>
  h2 {
    font-size: 2rem;
    text-align: center;
  }

  input {
    width: 100%;
  }

  .buttons {
    display: flex;
    width: 100%;
    justify-content: space-around;
  }
</style>
