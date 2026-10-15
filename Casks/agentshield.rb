cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2432"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2432/agentshield_0.2.2432_darwin_amd64.tar.gz"
      sha256 "91dfda220c969315ddbeb5935a96db98337534ad5896ffd29ba00883359c8a62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2432/agentshield_0.2.2432_darwin_arm64.tar.gz"
      sha256 "ae36c577d01119755053760c30625d551662d29ba3cd0714250a35540f6ff663"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2432/agentshield_0.2.2432_linux_amd64.tar.gz"
      sha256 "54a5f86249a6d4696ebbfdd065188a48ab2d2780e621aa1ea4884ab00519f696"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2432/agentshield_0.2.2432_linux_arm64.tar.gz"
      sha256 "bb69546fba50b36cebab103628ffc33af5e530c4e222d1df5dda4d86f6e9b96a"
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
