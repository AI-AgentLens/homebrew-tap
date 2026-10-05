cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2349"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2349/agentshield_0.2.2349_darwin_amd64.tar.gz"
      sha256 "1b36c5e3f6a7bac205bf3a553b86da18c5fb2ff2359cf8457a4a4837d6529ac0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2349/agentshield_0.2.2349_darwin_arm64.tar.gz"
      sha256 "2df151b0240466a5dd58dd9749e65c65e8cbdbd7737881d81d4e05f87e12623f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2349/agentshield_0.2.2349_linux_amd64.tar.gz"
      sha256 "3d0d6d3ef17000aa8fe9e5d81bd10b0364e41f5869809a808dcf51542c7fc3eb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2349/agentshield_0.2.2349_linux_arm64.tar.gz"
      sha256 "f23ce2816a17087180b29670866bc60a142a1dc08f573307e54251d33e0a7124"
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
