cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2330"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2330/agentshield_0.2.2330_darwin_amd64.tar.gz"
      sha256 "0f11a99588ed989200bd43b2aeb6c6e0a096d520e2440981edae7ff40e979cfd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2330/agentshield_0.2.2330_darwin_arm64.tar.gz"
      sha256 "19aa2a6529316d5ccfc43b0ba4e0ddf45b87a22b72d0bd1cbe2928a84bc7e4c8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2330/agentshield_0.2.2330_linux_amd64.tar.gz"
      sha256 "0d70aa20554b72b3869a27788104a3e9d27e87c35e7dcf7b7a63d671acf31ae3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2330/agentshield_0.2.2330_linux_arm64.tar.gz"
      sha256 "c45f95609f865df35457c5122fb0dd69414b40005009db709662373f64705f05"
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
