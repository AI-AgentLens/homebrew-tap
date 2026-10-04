cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2336"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2336/agentshield_0.2.2336_darwin_amd64.tar.gz"
      sha256 "d66e49201b4a33854cbbffea279f934b349d48cbfb411b29e37a1b432cea6e92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2336/agentshield_0.2.2336_darwin_arm64.tar.gz"
      sha256 "e3785fc9491d05e7c44a29d6a74631029f8aa2e9e1c0fd5c3750c478dd8d319a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2336/agentshield_0.2.2336_linux_amd64.tar.gz"
      sha256 "d5c40077be1eb7bbcfea5000e6d32cad4631fdd601e2d522a93326f30e44d5ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2336/agentshield_0.2.2336_linux_arm64.tar.gz"
      sha256 "1b6729510b32e64545e97a7ecbf0a55adb8c6e7431f0c1bfe823ed3aee0146d0"
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
