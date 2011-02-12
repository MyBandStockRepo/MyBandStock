class RedemptionObserver < ActiveRecord::Observer
  def after_create(record)
    admins = (Role.find_by_name("site_admin").users + record.reward.level.band.admins).uniq
    UserMailer.redemption_notification_to_admins(admins).deliver
    UserMailer.redemption_confirmation_to_user([record.user]).deliver
    record.user.reduce_net_shares_by_redemption_amount(record)
  end
end
