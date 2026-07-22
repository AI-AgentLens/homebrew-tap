cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1708"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1708/agentshield_0.2.1708_darwin_amd64.tar.gz"
      sha256 "b97f581e0d610e60bfd9a7f4503f1511aeb580090a4852f0045211203a725ab2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1708/agentshield_0.2.1708_darwin_arm64.tar.gz"
      sha256 "b2af0b7cdeefc0ebfb102e7f32acdd244f0b9c03a96d234d34b395b9c0190632"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1708/agentshield_0.2.1708_linux_amd64.tar.gz"
      sha256 "24388cdab02a5117f2df5fc46e26252c2770b482fa99689200b74ae7d43d8271"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1708/agentshield_0.2.1708_linux_arm64.tar.gz"
      sha256 "25e01025f351be12448c474feb82ded03ebcec1d6fc4fcf1d9c8318abf25351e"
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
