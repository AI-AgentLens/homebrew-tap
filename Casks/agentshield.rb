cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1357"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1357/agentshield_0.2.1357_darwin_amd64.tar.gz"
      sha256 "358c43b99af5dff42378a5be43759f51c3a9c090f5bd9e2235690f722893af30"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1357/agentshield_0.2.1357_darwin_arm64.tar.gz"
      sha256 "e2fedd6407d74cb71922fabb13efb2fe69f1b488ce333fc405b5769756e3fab3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1357/agentshield_0.2.1357_linux_amd64.tar.gz"
      sha256 "e04aa3a0855c8056fe021d06f89a22ff68317bea8bd5ac5a909a43b58d1d436a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1357/agentshield_0.2.1357_linux_arm64.tar.gz"
      sha256 "be929a230fa3e61a3af30e343dba8f74e061ad32f620ce73d329fcd506857d94"
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
