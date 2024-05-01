require "scc/instrumentable"

# Making things testable sometimes suck...
class TopLevelClassSubject
end

module FirstMod
  class SecondClass
    class ThirdClass
    end
  end
end
# / Making things testable sometimes suck...

RSpec.describe Scc::Instrumentable do
  describe "#instrumentation_namespace" do
    context "when class is not namespaced" do
      subject do
        TopLevelClassSubject.include(described_class).new
      end

      it "returns the class name in lowercase" do
        expect(subject.instrumentation_namespace).not_to match(/[A-Z]/)
      end

      it "snake-cases the name" do
        expect(subject.instrumentation_namespace).to eq("top_level_class_subject")
      end
    end

    context "when class is namespaced" do
      subject do
        FirstMod::SecondClass::ThirdClass.include(described_class).new
      end

      it "returns the class name in camelcase" do
        expect(subject.instrumentation_namespace).not_to match(/[A-Z]/)
      end

      it "includes the fully qualified class name in snake-cases", :aggregate_failures do
        expect(subject.instrumentation_namespace).to include("first_mod")
        expect(subject.instrumentation_namespace).to include("second_class")
        expect(subject.instrumentation_namespace).to include("third_class")
      end

      it "returns the name in reverse DNS notation: inner.middle.toplevel", :aggregate_failures do
        expect(subject.instrumentation_namespace).to eq("third_class.second_class.first_mod")
      end
    end
  end

  describe "#instrument" do
    subject do
      TopLevelClassSubject.include(described_class).new
    end

    it "calls ActiveSupport with a namespaced event" do
      allow(ActiveSupport::Notifications).to receive(:instrument)

      subject.instrument("event") { 2 + 2 }

      expect(ActiveSupport::Notifications).to have_received(:instrument)
        .once
        .with("event.top_level_class_subject", nil)
    end

    it "forwards the payload to ActiveSupport" do
      allow(ActiveSupport::Notifications).to receive(:instrument)

      subject.instrument("event", {data: :extra}) { 2 + 2 }

      expect(ActiveSupport::Notifications).to have_received(:instrument)
        .once
        .with("event.top_level_class_subject", {data: :extra})
    end
  end
end
