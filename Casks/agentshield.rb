cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1230"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1230/agentshield_0.2.1230_darwin_amd64.tar.gz"
      sha256 "b18caea74e8ea111f35c00ea3b0730f670b44559e1260e338b1e5721c3f31063"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1230/agentshield_0.2.1230_darwin_arm64.tar.gz"
      sha256 "9380f2301a62a899c7bf7052119d20b6bf99e3651db3b98860ffac0757a435af"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1230/agentshield_0.2.1230_linux_amd64.tar.gz"
      sha256 "5cd4623d2ce150972193e720014b62139938d668f099de94b0da9983a57cc242"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1230/agentshield_0.2.1230_linux_arm64.tar.gz"
      sha256 "f06ae895e45d3d5c26b6aab2004024dae71771624e07e4bdf689257376b44f61"
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
