cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1167"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1167/agentshield_0.2.1167_darwin_amd64.tar.gz"
      sha256 "8cb69d372f71698f9174b2e441c775246a574990aa14fce5d8cb0dea9569da6a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1167/agentshield_0.2.1167_darwin_arm64.tar.gz"
      sha256 "289162dbeb7c4cead45a13fd62c5b229470f2128d01a03dc1cb20d5d223ee4a4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1167/agentshield_0.2.1167_linux_amd64.tar.gz"
      sha256 "e36a2601e17f9ab18da423c5803985445d26a5aa0f2a23559df8e38a65ed796d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1167/agentshield_0.2.1167_linux_arm64.tar.gz"
      sha256 "4c3784aa347c71a3eccdabc8a2dad8971be66d337ad235a15b94741b695a6fee"
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
