cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.957"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.957/agentshield_0.2.957_darwin_amd64.tar.gz"
      sha256 "48d310aef2886f50d878a3ddce2beb431d128b5fa704dd1528583b6d509a42bc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.957/agentshield_0.2.957_darwin_arm64.tar.gz"
      sha256 "45542872c177411635d6f5960cb5d2f8ddcc3463077d664363ab1bf904ff146d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.957/agentshield_0.2.957_linux_amd64.tar.gz"
      sha256 "05f4c67be6701d8c7bf3dee2052bff232342e5c5e54d418900d5db3cca02f002"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.957/agentshield_0.2.957_linux_arm64.tar.gz"
      sha256 "341415724aa6453706e2987e2cb1664ecbad4c7a9b95ea9e7debcaf1c62ef7eb"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
