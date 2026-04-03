cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.352"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.352/agentshield_0.2.352_darwin_amd64.tar.gz"
      sha256 "328ba02f268605d242790b05ef0d93862aea504b4a506cd727a1f7f1ebd3b09a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.352/agentshield_0.2.352_darwin_arm64.tar.gz"
      sha256 "8e10ae30c5c7c45a3fac425138ce81cb9b5a6403b860e08c1c379eb0616d50c2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.352/agentshield_0.2.352_linux_amd64.tar.gz"
      sha256 "72c6db79a64baf2071349166baa9318bc5bcda7f39147ba13a12180f129b842f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.352/agentshield_0.2.352_linux_arm64.tar.gz"
      sha256 "1c974c3a1d5ae1712878f3558cf8c25f20868c91be6a6ded81b1187cee46e004"
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
