cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.228"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.228/agentshield_0.2.228_darwin_amd64.tar.gz"
      sha256 "167b73f2b96432364ef8d24d3219ddd5b72e7dcb8ea4dae1195c00feee72f2e1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.228/agentshield_0.2.228_darwin_arm64.tar.gz"
      sha256 "fc7e976cb5fd21a4938de0541b6bbb575c2db3c317f3cfd93a03f144e7229684"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.228/agentshield_0.2.228_linux_amd64.tar.gz"
      sha256 "dfcb859545d8e1860ecd12fd7cd0f369896545a1a291b55b6add5017b5f4b599"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.228/agentshield_0.2.228_linux_arm64.tar.gz"
      sha256 "1adf7fc5780ad82ab4696b5864bbfe677fae21c37e2ae6b71902cbcc9d4acdab"
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
