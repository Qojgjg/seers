<script>
  import { getContext } from "svelte"
  import Dialog from "./Dialog.svelte"

  export let onOk
  export let tokensEstimate
  export let outcome
  export let seerAmount
  export let buttonLabel

  const { open } = getContext("simple-modal")

  let opening = false
  let opened = false
  let closing = false
  let closed = false

  let name
  let status = 0

  const onCancel = () => {
    name = ""
    status = -1
  }

  const onOkay = () => {
    onOk()
    status = 1
  }

  const showDialog = () => {
    open(
      Dialog,
      {
        title: "Confirm Transaction",
        message: `Buying ${tokensEstimate.toFixed(
          2,
        )} shares of "${outcome}". Total cost is ${Number(seerAmount).toFixed(
          2,
        )} Σ`,
        hasForm: true,
        onCancel,
        onOkay,
      },
      {
        closeButton: false,
        closeOnEsc: false,
        closeOnOuterClick: false,
      },
    )
  }
</script>

<div
  style="width: 100%; justify-content: center; text-align: center; display: flex"
>
  <button class="btn-grad" on:click={showDialog}>{buttonLabel}</button>
</div>

<style>
</style>
