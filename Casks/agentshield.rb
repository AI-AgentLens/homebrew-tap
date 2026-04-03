cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.358"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.358/agentshield_0.2.358_darwin_amd64.tar.gz"
      sha256 "389bb97b484969900ba7a1c34266e421b6f8523e2261a52a87ef7a9587822b5f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.358/agentshield_0.2.358_darwin_arm64.tar.gz"
      sha256 "5a047c51639b637d39867fc93dab75cdb6b01264f1fe370aacc49bccedcc3514"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.358/agentshield_0.2.358_linux_amd64.tar.gz"
      sha256 "50cdae8933d708201d546e707afb67bed45733380b4750803ea5ef384246f7a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.358/agentshield_0.2.358_linux_arm64.tar.gz"
      sha256 "4309ceb34bde7dac09ede3af816ff0f37d0cb88623f92617f429ea3ed2cacf44"
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
