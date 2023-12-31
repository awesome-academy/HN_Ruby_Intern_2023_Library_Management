module Admin::BorrowsHelper
  def get_borrow_status borrow
    case borrow.status.to_sym
    when :pending then [:primary, :pending]
    when :renewing then [:info, :renewing]
    when :approved then [:success, :approved]
    when :rejected
      text = borrow.finished? ? :rejected : :renew_rejected
      [:danger, text]
    when :returned then [:warning, :returned]
    when :canceled then [:dark, :canceled]
    else [:secondary, borrow.status]
    end
  end

  def get_status_filter_for_group group
    group2options = {
      history: [:rejected, :returned, :canceled],
      borrowing: [:rejected, :approved],
      pending: [:pending, :renewing]
    }
    (group2options[group] << :all).index_by{|k| t(k)}
  end

  def populate_borrow borrow
    {
      user: borrow.account,
      full_name: borrow.account.user_info&.name,
      start: localize_date(borrow.renewing? ? borrow.end_at : borrow.start_at),
      due: localize_date(borrow.renewing? ? borrow.renewal_at : borrow.end_at),
      done: localize_date(borrow.done_at, :long),
      turns: pluralize(borrow.turns, t("borrows.turn")),
      borrow_path: admin_borrow_path(borrow)
    }
  end

  def get_borrow_buttons borrow
    if borrow.pending? || borrow.renewing?
      [
        {
          text: t("borrows.approve"),
          link: approve_admin_borrow_path(borrow),
          color: :success,
          confirm: t(".approve_confirm")
        },
        {
          text: t("borrows.reject"),
          link: reject_admin_borrow_path(borrow),
          color: :danger,
          data: {
            bs_toggle: :modal,
            bs_target: "#reject_response_modal"
          }
        }
      ]
    elsif borrow.borrowing?
      return_confirm = if borrow.overdue?
                         penalty = number_to_currency(borrow.penalty)
                         exceed = borrow.return_exceed
                         t ".overdue_confirm", penalty:, exceed:
                       else
                         t(".return_confirm")
                       end
      [
        {
          text: t("borrows.return"),
          link: return_admin_borrow_path(borrow),
          color: :primary,
          confirm: return_confirm
        },
        {
          text: t("borrows.remind"),
          link: remind_admin_borrow_path(borrow),
          color: :danger,
          confirm: t(".remind_confirm")
        }
      ]
    end
  end
end
