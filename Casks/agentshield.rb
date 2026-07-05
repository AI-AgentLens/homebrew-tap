cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1562"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1562/agentshield_0.2.1562_darwin_amd64.tar.gz"
      sha256 "f23a92b13620ea6e01889ac33329827d5ca25d1456602daf1d6167f51da48d50"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1562/agentshield_0.2.1562_darwin_arm64.tar.gz"
      sha256 "14fa35332e216628be22e6bf87470d1649786aff9cb266aed6a0a27c10d77832"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1562/agentshield_0.2.1562_linux_amd64.tar.gz"
      sha256 "9cfbaf8c1f645e8b3494a57623ecdb8c76cad512d868e5a7d755acea2a63c681"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1562/agentshield_0.2.1562_linux_arm64.tar.gz"
      sha256 "9bf6dfa2f91104d5967f680360a74ea802680ef000c1417fee32ccb26afc6706"
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
