$(() => {
  const voteButton = $("#vote_button"),
        delegationsButton = $("#delegations-button"),
        delegationCallouts = $(".delegation-callout"),
        delegationCalloutsMessage = $(".delegation-callout-message"),
        delegationDialog = $("#delegations-modal"),
        delegationVoteButtons = $(".delegation-vote-button"),
        delegationField = $("#decidim_consultations_delegation_id"),
        voteDialog = $("#question-vote-modal");

  delegationsButton.click(() => {
    delegationDialog.foundation("open");
  });

  delegationVoteButtons.click((e) => {
    delegationDialog.foundation("close");
    voteDialog.foundation("open");
    delegationField.val($(e.currentTarget).data("delegation-id"));
    delegationCalloutsMessage.text($(e.currentTarget).data("delegation-granter-name"));
    delegationCallouts.removeClass("is-hidden");
  });

  voteButton.click(() => {
    delegationCallouts.addClass("is-hidden");
  });
});
