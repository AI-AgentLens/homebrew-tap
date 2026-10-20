cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2478"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2478/agentshield_0.2.2478_darwin_amd64.tar.gz"
      sha256 "cdadb1537df048ba69551b4e150526c5d69548bac53dd0e9d946da63674b6bfa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2478/agentshield_0.2.2478_darwin_arm64.tar.gz"
      sha256 "61de32aa24a24d00a5e412c2d0a9b89488f0af79457ae11685b6685c3f670e97"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2478/agentshield_0.2.2478_linux_amd64.tar.gz"
      sha256 "76094aaa5208efb57d8af47dc45b6e608b5e886db9076d42c7737940f653e5b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2478/agentshield_0.2.2478_linux_arm64.tar.gz"
      sha256 "b7f803accfd406f41c0cd822cb30ff4a4a4baac8d085d30bfc656f8945c249ae"
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
