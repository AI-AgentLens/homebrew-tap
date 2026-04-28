cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.793"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.793/agentshield_0.2.793_darwin_amd64.tar.gz"
      sha256 "70152128fa583e33012dbe66b5f98df366ad0f277669a7a8783b3b2ace247c72"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.793/agentshield_0.2.793_darwin_arm64.tar.gz"
      sha256 "db57383ac1a8a130eab20a0e970d42819a0ddde6311cb4bde586fad6b373bd07"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.793/agentshield_0.2.793_linux_amd64.tar.gz"
      sha256 "e0ec5d6dd6f573ff58ff21859031f202dae490cc4510d04a1017944bb5a60956"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.793/agentshield_0.2.793_linux_arm64.tar.gz"
      sha256 "730d55f8ea09ff808c004703266b2d0847601a06d8be2eeaabdee79f4218e145"
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
