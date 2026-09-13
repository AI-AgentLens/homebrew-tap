cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2131"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2131/agentshield_0.2.2131_darwin_amd64.tar.gz"
      sha256 "292a65d48991fc05235ffbf2d2b9fcd4b6cff3fa845dd58c57e620de29da6ce5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2131/agentshield_0.2.2131_darwin_arm64.tar.gz"
      sha256 "46f38135e65ca4042f8677383a608bd6773fa14ce9c116bdce48671b8ce1f0fa"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2131/agentshield_0.2.2131_linux_amd64.tar.gz"
      sha256 "b92cd7b0d01ba2b19e7c7f10f919ee907a270a0d1312728108f8b52dd97246f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2131/agentshield_0.2.2131_linux_arm64.tar.gz"
      sha256 "f9fa9fce9e3addbb666d66d6020b4c68e14587bf95504feb6072463bf5de408a"
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
