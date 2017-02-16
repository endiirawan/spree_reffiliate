module Spree
  class Commission < Spree::Base
    has_many :transactions, class_name: 'Spree::CommissionTransaction', dependent: :restrict_with_error
    belongs_to :affiliate, class_name: 'Spree::Affiliate'

    validates :start_date, :end_date, presence: true
    validate :cannot_mark_unpaid
    validate :eligiblity_of_dates

    self.whitelisted_ransackable_associations = %w[affiliate]
    self.whitelisted_ransackable_attributes =  %w[start_date end_date]

    define_model_callbacks :mark_paid, only: :after

    after_mark_paid :lock_transactions

    def mark_paid!
      run_callbacks :mark_paid do
        update_attributes!(paid: true)
      end
    end

    private
      def lock_transactions
        transactions.update_all(locked: true)
      end

      def cannot_mark_unpaid
        errors.add(:base, Spree.t(:cannot_mark_unpaid, scope: :commission)) if !paid? && paid_changed?
      end

      def eligiblity_of_dates
        errors.add(:base, Spree.t(:unsuitable_date_range, scope: :commission) ) if (start_date > end_date)
        errors.add(:base, Spree.t(:dates_ineligible, scope: :commission) ) if (start_date < Time.current.beginning_of_month || end_date > Time.current.end_of_month)
      end
  end
end