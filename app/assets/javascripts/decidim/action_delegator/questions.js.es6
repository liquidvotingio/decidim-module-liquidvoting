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
    voteDialog.foundation("open");
    delegationField.val($(e.target).data("delegation-id"));
    delegationCalloutsMessage.text($(e.target).data("delegation-granter-name"));
    delegationCallouts.removeClass("is-hidden");
  });

  voteButton.click(() => {
    delegationCallouts.addClass("is-hidden");
  });
});
