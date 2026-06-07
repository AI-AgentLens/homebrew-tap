cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1244"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1244/agentshield_0.2.1244_darwin_amd64.tar.gz"
      sha256 "1899e4e3430019751ceacbc3917998afe79cba3b2444e16f6ce3f22ac29bae43"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1244/agentshield_0.2.1244_darwin_arm64.tar.gz"
      sha256 "9f06e442fb5686f88bf3957391417ca46a5d5f57a8eca6c351759cf85aa6f02c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1244/agentshield_0.2.1244_linux_amd64.tar.gz"
      sha256 "28f21b39ddb00bc788fd65e8f81ceff4877bf5927b44031f5f8cdb274bda0f46"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1244/agentshield_0.2.1244_linux_arm64.tar.gz"
      sha256 "1cf9d790922d41214a713d1376be9868ccd8320bb6f522518f89213eaea2964d"
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
