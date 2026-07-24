cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1720"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1720/agentshield_0.2.1720_darwin_amd64.tar.gz"
      sha256 "ff2161b2fb0c86eb714a9a835e7fd4b8fde172b6c09eb89980940b245625dc6c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1720/agentshield_0.2.1720_darwin_arm64.tar.gz"
      sha256 "f229bfa5890b04397839a67697e76a5328db1e7c2446e43ee0a655471f38b079"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1720/agentshield_0.2.1720_linux_amd64.tar.gz"
      sha256 "ada18bccb06b84056b7e4c106c83a7b0a84c1c062a6271b5acba12dce318f10d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1720/agentshield_0.2.1720_linux_arm64.tar.gz"
      sha256 "531ea3f18749f4d865f9ea922300de75e832caccaefa8460a29d61ccbba9f666"
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
